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

/// Reified in-place changes for collections. This type is effectively
/// `Change<Cursor<C>>` but with better naming and simpler use.
public enum CollectionChange<C: CollectionType> {
    case Insert(Cursor<C>)
    case Remove(Cursor<C>)

    /// Insert in-place semantics for collections.
    public static func insert<C: CollectionType>(element: C.Generator.Element, atIndex index: C.Index) -> CollectionChange<C> {
        return .Insert(Cursor(element: element, index: index))
    }
    
    /// Remove in-place semantics for collections.
    public static func remove<C: CollectionType>(element: C.Generator.Element, atIndex index: C.Index) -> CollectionChange<C> {
        return .Remove(Cursor(element: element, index: index))
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: CollectionChange<C>, rhs: CollectionChange<C>) -> Bool {
    switch (lhs, rhs) {
    case let (.Insert(left), .Insert(right)):
        return left == right
    case let (.Remove(left), .Remove(right)):
        return left == right
    default:
        return false
    }
}