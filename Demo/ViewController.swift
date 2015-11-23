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

class TextCell: UICollectionViewCell {
    private var label: UILabel!

    var text: String = "" {
        didSet {
            label.text = text
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: bounds)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        self.addSubview(label)
    }
}

extension QueueScheduler {
    func delay(interval: NSTimeInterval, action: () -> ()) {
        scheduleAfter(NSDate(timeIntervalSinceNow: interval), action: action)
    }
}

class ViewController: UIViewController {

    var dataSource: CollectionViewDataSource<Int>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = UICollectionViewFlowLayout();
        let collectionView = UICollectionView(frame: CGRectMake(10, 20, 300, 400), collectionViewLayout: flowLayout);
        collectionView.registerClass(TextCell.self, forCellWithReuseIdentifier: "cell");
        collectionView.backgroundColor = UIColor.cyanColor();

        var array = ObservableArray<Int>()
        array.replaceRange(0..<0, with: [1, 2, 3, 4, 5, 6, 7, 8])

        dataSource = CollectionViewDataSource(collectionView: collectionView, producer: array.observe()) { value, collectionView, indexPath in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TextCell
            cell.text = "\(value)"

            switch value % 3 {
            case 0: cell.backgroundColor = UIColor.greenColor()
            case 1: cell.backgroundColor = UIColor.redColor()
            case 2: cell.backgroundColor = UIColor.blueColor()
            default: fatalError()
            }

            return cell
        }

        view.addSubview(collectionView)

        QueueScheduler.mainQueueScheduler.delay(0.1) { array.replaceRange(1..<3, with: [3, 2, 1, 0]) }
        QueueScheduler.mainQueueScheduler.delay(0.2) { array.replaceRange(2..<6, with: [9, 10]) }
        QueueScheduler.mainQueueScheduler.delay(0.3) { array[0] = 0 }
        QueueScheduler.mainQueueScheduler.delay(0.4) { array.appendContentsOf([11, 12]) }
        QueueScheduler.mainQueueScheduler.delay(0.5) { array.removeFirst(3) }
    }
}

