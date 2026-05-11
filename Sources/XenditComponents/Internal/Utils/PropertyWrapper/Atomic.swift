//
//  Atomic.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

@propertyWrapper
struct Atomic<T> {
    typealias ChangeHandler = (T) -> Void

    private let lock = NSLock()
    private var value: T
    private let changeHandler: ChangeHandler?

    var wrappedValue: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
            changeHandler?(newValue)
        }
    }

    init(default value: T, onChange: ChangeHandler? = nil) {
        self.value = value
        changeHandler = onChange
    }
}
