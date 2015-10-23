//
//  CollectionEvent.swift
//  Rex
//
//  Created by Neil Pankey on 10/23/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

public enum CollectionEvent<Collection: CollectionType> {
    case Insert(Cursor<Collection>)
    case Remove(Cursor<Collection>)
    case Composite([CollectionEvent])
    
    public static func insert(element: Collection.Generator.Element, at index: Collection.Index) -> CollectionEvent {
        return .Insert(Cursor(element: element, index: index))
    }

    public static func remove(element: Collection.Generator.Element, at index: Collection.Index) -> CollectionEvent {
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
