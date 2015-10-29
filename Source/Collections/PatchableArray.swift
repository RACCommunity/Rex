//
//  PatchableArray.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

extension Array: Patchable {
    public typealias Patch = Delta<CollectionChange<[Element]>>

    @warn_unused_result
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
    
    private mutating func changeInPlace(change: CollectionChange<[Element]>) {
        switch change {
        case let .Insert(focus):
            insert(focus.element, atIndex: focus.index)
        case let .Remove(focus):
            removeAtIndex(focus.index)
        }
    }
}
