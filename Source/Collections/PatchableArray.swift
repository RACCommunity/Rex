//
//  PatchableArray.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

extension Array: Patchable {
    public typealias Focus = Cursor<[Element]>
    public typealias Patch = Delta<Focus>
    
    public func apply(patch: Patch) -> Array {
        var clone = self

        switch patch {
        case let .Single(change):
            clone.changeInPlace(change)
        case let .Batch(changes):
            for change in changes {
                clone.changeInPlace(change)
            }
        }

        return clone
    }
    
    private mutating func changeInPlace(change: Change<Cursor<[Element]>>) {
        switch change {
        case let .Assert(focus):
            insert(focus.element, atIndex: focus.index)
        case let .Retract(focus):
            removeAtIndex(focus.index)
        }
    }
}
