//
//  UICollectionView.swift
//  Rex
//
//  See https://gist.github.com/andymatuschak/f1e1691fa1a327468f8e
//
//  Created by Andy Matuschak on 10/14/14.
//  Copyright (c) 2014 Khan Academy. All rights reserved.
//

import ReactiveCocoa
import UIKit

extension UICollectionView {
    /// Creates an animation producer from a set of collection changes.
    public func animatePatch<C: CollectionType where C.Index == Int>(patch: [CollectionChange<C>]) -> SignalProducer<(), NoError> {
        return SignalProducer { observer, _ in
            self.performBatchUpdates({
                patch.forEach {
                    switch $0 {
                    case let .Insert(cursor):
                        self.insertItemsAtIndexPaths([NSIndexPath(forItem: cursor.index, inSection: 0)])
                    case let .Remove(cursor):
                        self.deleteItemsAtIndexPaths([NSIndexPath(forItem: cursor.index, inSection: 0)])
                    }
                }
            }, completion: { _ in
                observer.sendCompleted()
            })
        }
    }
}

public final class CollectionViewDataSource<Element>: NSObject, UICollectionViewDataSource {
    public typealias PatchProducer = SignalProducer<[CollectionChange<[Element]>], NoError>
    public typealias ObserveProducer = SignalProducer<([Element], PatchProducer), NoError>
    public typealias Configure = (Element, UICollectionView, NSIndexPath) -> UICollectionViewCell

    private var elements: [Element] = []
    private var configure: Configure

    /// Attaches self as the `collectionView`s data source using `producer`
    public init(collectionView: UICollectionView, producer: ObserveProducer, configure: Configure) {
        self.configure = configure
        super.init()

        collectionView.dataSource = self

        producer.flatMap(.Latest) { (elements, patches) -> PatchProducer in
            precondition(collectionView.dataSource === self, "Data source changed!")

            // Force reload if the backing set of elements reset
            self.elements = elements
            collectionView.reloadData()

            return patches
        }
        .flatMap(.Concat) { (patch) -> SignalProducer<(), NoError> in
            precondition(collectionView.dataSource === self, "Data source changed!")

            // Defer changes until each set of animations completes. This avoids a nasty
            // class of bugs where you can delete items that are animating and crash the
            // collection view.
            return collectionView.animatePatch(patch).on(started: {
                self.elements = self.elements.apply(patch)
            })
        }
        .start { _ in return }
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return configure(elements[indexPath.item], collectionView, indexPath)
    }
}
