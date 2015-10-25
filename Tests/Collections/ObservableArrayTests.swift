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
        var patch: Delta<CollectionChange<[Int]>>!

        array.observe().startWithNext { _, patches in
            patches.startWithNext { patch = $0 }
        }

        array.insert(5, atIndex: 0)
        XCTAssert(patch == .Single(.insert(5, atIndex: 0)))

        array.insert(0, atIndex: 1)
        XCTAssert(patch == .Single(.insert(0, atIndex: 1)))

        array.replaceRange(1..<1, with: [4, 3, 2])
        XCTAssert(patch == .Batch([.insert(4, atIndex: 1), .insert(3, atIndex: 2), .insert(2, atIndex: 3)]))

        array.removeAtIndex(0)
        XCTAssert(patch == .Single(.remove(5, atIndex: 0)))
    }
}
