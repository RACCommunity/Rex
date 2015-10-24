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
}
