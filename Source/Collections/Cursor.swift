//
//  Cursor.swift
//  Rex
//
//  Created by Neil Pankey on 10/23/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

/// Focus on an element and it's index over a collection of items.
public struct Cursor<Collection: CollectionType> {
    public let element: Collection.Generator.Element
    public let index: Collection.Index
    
    public init(element: Collection.Generator.Element, index: Collection.Index) {
        self.element = element
        self.index = index
    }
}

extension Cursor: CustomStringConvertible {
    public var description: String {
        return "\(element) @\(index)"
    }
}

public func == <C: CollectionType where C.Generator.Element: Equatable>(lhs: Cursor<C>, rhs: Cursor<C>) -> Bool {
    return lhs.index == rhs.index && lhs.element == rhs.element
}
