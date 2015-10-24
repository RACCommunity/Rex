//
//  Patchable.swift
//  Rex
//
//  Created by Neil Pankey on 10/24/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

/// Any state that can be patched to produce a new state.
public protocol Patchable {
    /// A reified change type.
    typealias Patch

    /// Apply `patch` to generate a new version of self.
    func apply(patch: Patch) -> Self
}
