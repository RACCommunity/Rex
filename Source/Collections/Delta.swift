//
//  Delta.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

/// Atomic unit(s) of change supporting composition.
public enum Delta<T> {
    /// An single unit of change.
    case Single(T)
    /// An ordered list of changes (may be empty). Can be used for things
    /// like setters, or move/replace in a container context.
    case Batch([T])
}

public func == <T: Equatable>(lhs: Delta<Change<T>>, rhs: Delta<Change<T>>) -> Bool {
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

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: Delta<CollectionChange<C>>, rhs: Delta<CollectionChange<C>>) -> Bool {
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

