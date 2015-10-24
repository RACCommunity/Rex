//
//  Change.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

/// Simplest type of state change (inspired by Datomic). All state
/// changes are accumulated by asserting or retracting "stuff".
public enum Change<T> {
    case Assert(T)
    case Retract(T)
}

public func == <T: Equatable>(lhs: Change<T>, rhs: Change<T>) -> Bool {
    switch (lhs, rhs) {
    case let (.Assert(left), .Assert(right)):
        return left == right
    case let (.Retract(left), .Retract(right)):
        return left == right
    default:
        return false
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: Change<Cursor<C>>, rhs: Change<Cursor<C>>) -> Bool {
    switch (lhs, rhs) {
    case let (.Assert(left), .Assert(right)):
        return left == right
    case let (.Retract(left), .Retract(right)):
        return left == right
    default:
        return false
    }
}