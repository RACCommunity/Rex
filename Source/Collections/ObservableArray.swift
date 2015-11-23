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
        let patch: [CollectionChange<[Element]>]
        let removes: [CollectionChange<[Element]>] = subRange.map {
            .Remove(Cursor(element: self.elements[$0], index: $0))
        }
        let inserts: [CollectionChange<[Element]>] = newElements.enumerate().map {
            .Insert(Cursor(element: $1, index: $0 + subRange.startIndex))
        }
        patch = merge(removes, inserts)
        
        sinks.withValue {
            self.elements.replaceRange(subRange, with: newElements)
            $0.forEach { $0.sendNext(patch) }
        }
    }
}

/// Similar to `zip` but interleaves the elements into a single collection. Unlike
/// `zip`, this will exhaust both collections even if they are different sizes.
private func merge<C: CollectionType where C.Index == Int>(lhs: C, _ rhs: C) -> [C.Generator.Element] {
    var result: [C.Generator.Element] = []
    result.reserveCapacity(lhs.count + rhs.count)

    var (leftGenerator, rightGenerator) = (lhs.generate(), rhs.generate())
    var (leftElement, rightElement) = (leftGenerator.next(), rightGenerator.next())
    
    while leftElement != nil || rightElement != nil {
        if let leftValue = leftElement {
            result.append(leftValue)
            leftElement = leftGenerator.next()
        }
        if let rightValue = rightElement {
            result.append(rightValue)
            rightElement = rightGenerator.next()
        }
    }
    
    return result
}
