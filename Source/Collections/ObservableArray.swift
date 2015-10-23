//
//  ObservableArray.swift
//  Rex
//
//  Created by Neil Pankey on 10/23/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

public final class ObservableArray<Element>: ObservableCollectionType {
    public typealias CollectionChange = CollectionEvent<[Element]>
    public typealias ChangesProducer = SignalProducer<CollectionChange, NoError>
    public typealias ObserveProducer = SignalProducer<([Element], ChangesProducer), NoError>
    
    public init() {
    }
    
    public var collection: [Element] {
        return elements
    }
    
    public func observe() -> ObserveProducer {
        return SignalProducer { observer, disposable in
            let (producer, sink) = ChangesProducer.buffer()
            var token: RemovalToken!
            
            self.sinks.modify { (var sinks) in
                token = sinks.insert(sink)
                observer.sendNext((self.elements, producer))
                return sinks
            }
            
            disposable.addDisposable {
                self.sinks.modify { (var sinks) in
                    sinks.removeValueForToken(token)
                    return sinks
                }
            }
        }
    }
    
    private var elements: [Element] = []
    private var sinks: Atomic<Bag<ChangesProducer.ProducedSignal.Observer>> = Atomic(Bag())
}

extension ObservableArray:  MutableCollectionType {
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set(newValue) {
            replaceRange(index..<index, with: [newValue])
        }
    }
    
    public func generate() -> Array<Element>.Generator {
        return elements.generate()
    }
}

extension ObservableArray: RangeReplaceableCollectionType {
    public func replaceRange<C : CollectionType where C.Generator.Element == Element>(subRange: Range<Int>, with newElements: C) {
        let removes: [CollectionChange] = subRange.map { .remove(self.elements[$0], at: subRange.startIndex) }
        let inserts: [CollectionChange] = newElements.enumerate().map { .insert($1, at: $0 + subRange.startIndex) }
        
        let change: CollectionChange
        switch (removes.count, inserts.count) {
        case (0, 1):
            change = inserts[0]
        case (1, 0):
            change = removes[0]
        default:
            change = .Composite(removes + inserts)
        }
        
        sinks.withValue {
            self.elements.replaceRange(subRange, with: newElements)
            $0.forEach { $0.sendNext(change) }
        }
    }
}
