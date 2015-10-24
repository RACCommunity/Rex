//
//  Observable.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

/// Represents an observable environment. This is essentially RAC's `PropertyType` when
/// `State` and `Patch` are equivalent. This model can provide more efficiency for composite
/// types (e.g. collections) since you can reify smaller changes without cloning.
///
/// N.B. This should subsume ObservableCollectionType
public protocol Observable {
    typealias State
    typealias Patch

    var state: State { get }

    func observe() -> SignalProducer<(State, SignalProducer<Patch, NoError>), NoError>
}
