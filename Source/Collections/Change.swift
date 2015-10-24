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
