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
    public func applyPatch<C: CollectionType where C.Index == Int>(patch: [CollectionChange<C>]) {
        patch.forEach {
            switch $0 {
            case let .Insert(cursor):
                insertItemsAtIndexPaths([NSIndexPath(forItem: cursor.index, inSection: 0)])
            case let .Remove(cursor):
                deleteItemsAtIndexPaths([NSIndexPath(forItem: cursor.index, inSection: 0)])
            }
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

        producer.startWithNext { elements, patches in
            precondition(collectionView.dataSource === self, "Data source changed!")
            
            self.elements = elements
            collectionView.reloadData()

            patches.startWithNext { patch in
                precondition(collectionView.dataSource === self, "Data source changed!")

                self.elements = self.elements.apply(patch)

                collectionView.performBatchUpdates({
                    collectionView.applyPatch(patch)
                }, completion: nil)
            }
        }
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return configure(elements[indexPath.item], collectionView, indexPath)
    }
}
