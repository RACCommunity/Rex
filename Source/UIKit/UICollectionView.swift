//
//  UICollectionView.swift
//  Rex
//
//  Created by Neil Pankey on 10/25/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa
import UIKit

public protocol CollectionViewCellType {
    func configure(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell
}

public final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    public typealias PatchProducer = SignalProducer<Delta<CollectionChange<[CollectionViewCellType]>>, NoError>
    
    private var cells: [CollectionViewCellType] = []

    /// Attaches self as the `collectionView`s data source using `producer`
    public init(collectionView: UICollectionView, producer: SignalProducer<([CollectionViewCellType], PatchProducer), NoError>) {
        super.init()
        collectionView.dataSource = self

        producer.startWithNext { cells, patches in
            self.cells = cells
            collectionView.reloadData()

            patches.startWithNext { patch in
                self.cells.apply(patch)
                // TODO Inspect the patch
                collectionView.reloadData()
            }
        }
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cells[indexPath.item].configure(collectionView, indexPath: indexPath)
    }
}
