//
//  ObservableArrayTests.swift
//  Rex
//
//  Created by Neil Pankey on 10/23/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import Rex
import XCTest

class ObservableArrayTests: XCTestCase {

    func testObservation() {
        var array = ObservableArray<Int>()
        var change: CollectionEvent<[Int]>!

        array.observe().startWithNext { _, changes in
            changes.startWithNext { change = $0 }
        }

        array.insert(5, atIndex: 0)
        XCTAssert(change == .insert(5, at: 0))

        array.insert(0, atIndex: 1)
        XCTAssert(change == .insert(0, at: 1))

        array.replaceRange(1..<1, with: [4, 3, 2])
        XCTAssert(change == .Composite([.insert(4, at: 1), .insert(3, at: 2), .insert(2, at: 3)]))

        array.removeAtIndex(2)
        XCTAssert(change == .remove(3, at: 2))
    }
}
