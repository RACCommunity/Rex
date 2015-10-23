//
//  Query.swift
//  Rex
//
//  Created by Neil Pankey on 10/20/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

public enum CollectionEvent<Collection: CollectionType> {
    case Insert(Collection.Generator.Element, Collection.Index)
    case Remove(Collection.Generator.Element, Collection.Index)
    case Composite([CollectionEvent])
}

extension CollectionEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .Insert(element, index):
            return "INSERT: \(element) @\(index)"
        case let .Remove(element, index):
            return "REMOVE: \(element) @\(index)"
        case let .Composite(changes):
            let joined = changes.map { "<\($0.description)>" }.joinWithSeparator(", ")
            return "{ \(joined) }"
        }
    }
}

public protocol ObservableCollectionType {
    typealias Collection: CollectionType

    /// Read-only access to the underlying collection. These _should_ be copy-on-write
    /// to avoid a copy on each access while still allowing the callee to update the
    /// returned collection.
    ///
    /// N.B. Investigate clojure vector because CoW is still expensive.
    var collection: Collection { get }

    /// Safely subscribe to changes on `collection`.
    func observe() -> SignalProducer<(Collection, SignalProducer<CollectionEvent<Collection>, NoError>), NoError>
}

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
        let removes: [CollectionChange] = subRange.map { .Remove(self.elements[$0], subRange.startIndex) }
        let inserts: [CollectionChange] = newElements.enumerate().map { .Insert($1, $0 + subRange.startIndex) }
        
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
