//
//  UISwitch.swift
//  Rex
//
//  Created by David Rodrigues on 07/04/16.
//  Copyright © 2016 Neil Pankey. All rights reserved.
//

import ReactiveCocoa
import UIKit

extension UISwitch {
    @available(*, unavailable, renamed:"rex_isOn")
    public var rex_on: MutableProperty<Bool> { fatalError() }

    /// Wraps a switch's `on` value in a bindable property.
    public var rex_isOn: MutableProperty<Bool> {
        return UIControl.rex_value(self, getter: { $0.isOn }, setter: { $0.isOn = $1 })
    }
}
