//
//  UIView.swift
//  Rex
//
//  Created by Andy Jacobs on 21/10/15.
//  Copyright © 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa
import UIKit

extension UIView: BindingsProviding {}

extension BindingsProtocol where Owner: UIView {
    /// Wraps a view's `alpha` value in a bindable property.
    public var alpha: MutableProperty<CGFloat> {
        return associatedProperty(owner,
                                  key: &alphaKey,
                                  initial: { $0.alpha },
                                  setter: { $0.alpha = $1 })
    }
    
    /// Wraps a view's `isHidden` state in a bindable property.
    public var isHidden: MutableProperty<Bool> {
        return associatedProperty(owner,
                                  key: &hiddenKey,
                                  initial: { $0.isHidden },
                                  setter: { $0.isHidden = $1 })
    }
    

    /// Wraps a view's `isUserInteractionEnabled` state in a bindable property.
    public var isUserInteractionEnabled: MutableProperty<Bool> {
        return associatedProperty(owner,
                                  key: &userInteractionEnabledKey,
                                  initial: { $0.isUserInteractionEnabled },
                                  setter: { $0.isUserInteractionEnabled = $1 })
    }
}

private var alphaKey: UInt8 = 0
private var hiddenKey: UInt8 = 0
private var userInteractionEnabledKey: UInt8 = 0
