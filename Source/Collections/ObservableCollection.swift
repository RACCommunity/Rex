//
//  Query.swift
//  Rex
//
//  Created by Neil Pankey on 10/20/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

public protocol ObservableCollectionType {
    typealias Collection: CollectionType

    /// Read-only access to the underlying collection. These _should_ be copy-on-write
    /// to avoid a copy on each access while still allowing the callee to update the
    /// returned collection.
    ///
    /// N.B. Investigate clojure vector because CoW is still expensive.
    var collection: Collection { get }

    /// Safely subscribe to changes on `collection`.
    func observe() -> SignalProducer<(Collection, SignalProducer<CollectionEvent<Collection>, NoError>), NoError>
}

