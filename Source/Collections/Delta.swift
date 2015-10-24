//
//  Delta.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

/// Composing atomic changes from assertions and retractions.
public enum Delta<T> {
    /// An atomic unit of change.
    case Single(Change<T>)
    /// An atomic, ordered list of changes (may be empty). Can be used for things
    /// like setters, or move/replace in a container context.
    case Batch([Change<T>])
    // TODO: Is a tree of changes useful?
    // case Composite([Delta<T>])

    /// Insert in-place semantics for collections.
    public static func insert<C: CollectionType>(element: C.Generator.Element, atIndex index: C.Index) -> Delta<Cursor<C>> {
        return .Single(.insert(element, atIndex: index))
    }
    
    /// Remove in-place semantics for collections.
    public static func remove<C: CollectionType>(element: C.Generator.Element, atIndex index: C.Index) -> Delta<Cursor<C>> {
        return .Single(.remove(element, atIndex: index))
    }
}

public func == <T: Equatable>(lhs: Delta<T>, rhs: Delta<T>) -> Bool {
    switch (lhs, rhs) {
    case let (.Single(left), .Single(right)):
        return left == right
    case let (.Batch(left), .Batch(right)):
        if left.count == right.count {
            return zip(left, right).map { $0 == $1 }.reduce(true) { $0 && $1 }
        }
        return false
    default:
        return false
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: Delta<Cursor<C>>, rhs: Delta<Cursor<C>>) -> Bool {
    switch (lhs, rhs) {
    case let (.Single(left), .Single(right)):
        return left == right
    case let (.Batch(left), .Batch(right)):
        if left.count == right.count {
            return zip(left, right).map { $0 == $1 }.reduce(true) { $0 && $1 }
        }
        return false
    default:
        return false
    }
}

