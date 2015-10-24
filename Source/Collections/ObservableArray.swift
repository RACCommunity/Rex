//
//  ObservableArray.swift
//  Rex
//
//  Created by Neil Pankey on 10/23/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

public final class ObservableArray<Element>: Observable {
    public typealias State = Array<Element>
    public typealias PatchProducer = SignalProducer<State.Patch, NoError>
    public typealias ObserveProducer = SignalProducer<(State, PatchProducer), NoError>
    
    public init() {
    }
    
    public var state: [Element] {
        return elements
    }
    
    public func observe() -> ObserveProducer {
        return SignalProducer { observer, disposable in
            let (producer, sink) = PatchProducer.buffer()
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
    private var sinks: Atomic<Bag<PatchProducer.ProducedSignal.Observer>> = Atomic(Bag())
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
        let change: Delta<State.Focus>
        switch (subRange.count, newElements.count) {
        case (0, 1):
            change = .insert(newElements.first!, atIndex: subRange.startIndex)
        case (1, 0):
            change = .remove(elements[subRange.startIndex], atIndex: subRange.startIndex)
        default:
            let removes: [Change<State.Focus>] = subRange.map {
                .Retract(Cursor(element: self.elements[$0], index: subRange.startIndex))
            }
            let inserts: [Change<State.Focus>] = newElements.enumerate().map {
                .Assert(Cursor(element: $1, index: $0 + subRange.startIndex))
            }
            change = .Batch(removes + inserts)
        }
        
        sinks.withValue {
            self.elements.replaceRange(subRange, with: newElements)
            $0.forEach { $0.sendNext(change) }
        }
    }
}
