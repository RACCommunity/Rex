//
//  ViewController.swift
//  RexDemo
//
//  Created by Neil Pankey on 10/25/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

import UIKit
import Rex
import ReactiveCocoa

class ViewController: UIViewController {

    var dataSource: CollectionViewDataSource<Int>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = UICollectionViewFlowLayout();
        let collectionView = UICollectionView(frame: CGRectMake(10, 10, 300, 400), collectionViewLayout: flowLayout);
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell");
        collectionView.backgroundColor = UIColor.cyanColor();
        
        let array = ObservableArray<Int>()
        array.replaceRange(0..<0, with: [1, 2, 3, 4, 5, 6, 7, 8])
        
        dataSource = CollectionViewDataSource(collectionView: collectionView, producer: array.observe()) { value, collectionView, indexPath in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)

            switch value % 3 {
            case 0: cell.backgroundColor = UIColor.greenColor()
            case 1: cell.backgroundColor = UIColor.redColor()
            case 2: cell.backgroundColor = UIColor.blueColor()
            default: fatalError()
            }
            return cell
        }

        view.addSubview(collectionView)

        QueueScheduler.mainQueueScheduler.scheduleAfter(NSDate(timeIntervalSinceNow: 1)) {
            array.replaceRange(0..<0, with: [3, 2, 1, 0])
        }
    }
}

