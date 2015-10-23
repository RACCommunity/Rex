//
//  Query.swift
//  Rex
//
//  Created by Neil Pankey on 10/20/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

/// Focus on an element and it's index over a collection of items.
public struct Cursor<Collection: CollectionType> {
    public let element: Collection.Generator.Element
    public let index: Collection.Index
}

extension Cursor: CustomStringConvertible {
    public var description: String {
        return "\(element) @\(index)"
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: Cursor<C>, rhs: Cursor<C>) -> Bool {
    return lhs.index == rhs.index && lhs.element == rhs.element
}

public enum CollectionEvent<Collection: CollectionType> {
    case Insert(Cursor<Collection>)
    case Remove(Cursor<Collection>)
    case Composite([CollectionEvent])
    
    public static func insert(element: Collection.Generator.Element, _ index: Collection.Index) -> CollectionEvent {
        return .Insert(Cursor(element: element, index: index))
    }

    public static func remove(element: Collection.Generator.Element, _ index: Collection.Index) -> CollectionEvent {
        return .Remove(Cursor(element: element, index: index))
    }
}

extension CollectionEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .Insert(cursor):
            return "INSERT: \(cursor)"
        case let .Remove(cursor):
            return "REMOVE: \(cursor)"
        case let .Composite(changes):
            let joined = changes.map { "<\($0.description)>" }.joinWithSeparator(", ")
            return "{ \(joined) }"
        }
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: CollectionEvent<C>, rhs: CollectionEvent<C>) -> Bool {
    switch (lhs, rhs) {
    case let (.Insert(left), .Insert(right)):
        return left == right
    case let (.Remove(left), .Remove(right)):
        return left == right
    case let (.Composite(left), .Composite(right)):
        if left.count == right.count {
            return zip(left, right).map { $0 == $1 }.reduce(true) { $0 && $1 }
        }
        return false
    default:
        return false
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
        let removes: [CollectionChange] = subRange.map { .remove(self.elements[$0], subRange.startIndex) }
        let inserts: [CollectionChange] = newElements.enumerate().map { .insert($1, $0 + subRange.startIndex) }
        
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
