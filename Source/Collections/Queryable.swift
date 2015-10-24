//
//  Queryable.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

// TODO Is this even valuable?

/// Anything that can be queried returning an observable result.
public protocol Queryable {
    typealias Query
    typealias Error: ErrorType
    typealias Result: Observable
    
    /// Execute a query returning an observable result
    func query(q: Query) -> SignalProducer<Result, Error>
}
