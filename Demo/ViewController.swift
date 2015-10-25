//
//  ViewController.swift
//  RexDemo
//
//  Created by Neil Pankey on 10/25/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

import UIKit
import Rex

public final class Color: CollectionViewCell {
    func configure(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
}

class ViewController: UIViewController, UICollectionViewDataSource {
    
    var dataSource: CollectionViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = UICollectionViewFlowLayout();
        let collectionView = UICollectionView(frame: CGRectMake(10, 10, 300, 400), collectionViewLayout: flowLayout);
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell");
        collectionView.backgroundColor = UIColor.cyanColor();
        
        let array = ObservableArray<Color>()
        array.replaceRange(0..<0, with: Array<Color>(count: 10, repeatedValue: Color()))
        
        dataSource = CollectionViewDataSource(collectionView: collectionView, producer: array.observe())

        // Do any additional setup after loading the view, typically from a nib.
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
}

