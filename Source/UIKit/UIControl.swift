//
//  UIView.swift
//  Rex
//
//  Created by Neil Pankey on 6/19/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import UIKit
import enum Result.NoError

extension UIControl {

#if os(iOS)
    /// Creates a producer for the sender whenever a specified control event is triggered.
    public func rex_controlEvents(_ events: UIControlEvents) -> SignalProducer<UIControl?, NoError> {
        return rac_signal(for: events)
            .toSignalProducer()
            .map { $0 as? UIControl }
            .flatMapError { _ in SignalProducer(value: nil) }
    }

    /// Creates a bindable property to wrap a control's value.
    /// 
    /// This property uses `UIControlEvents.ValueChanged` and `UIControlEvents.EditingChanged` 
    /// events to detect changes and keep the value up-to-date.
    //
    class func rex_value<Host: UIControl, T>(_ host: Host, getter: @escaping (Host) -> T, setter: @escaping (Host, T) -> ()) -> MutableProperty<T> {
        return associatedProperty(host, key: &valueChangedKey, initial: getter, setter: setter) { property in
            property <~
                host.rex_controlEvents([.valueChanged, .editingChanged])
                    .filterMap { $0 as? Host }
                    .filterMap(getter)
        }
    }
#endif

}

private var valueChangedKey: UInt8 = 0
