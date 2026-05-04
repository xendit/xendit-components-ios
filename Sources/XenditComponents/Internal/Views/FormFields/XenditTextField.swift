//
//  XenditTextField.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI
import UIKit

/// UIViewRepresentable wrapper around UITextField that enforces character filters and max
/// length at the UIKit layer, preventing SwiftUI's binding-update lag from letting extra
/// characters appear when the user types past a limit.
///
/// Usage:
/// ```swift
/// XenditTextField(text: $value, placeholder: "Card number",
///     keyboardType: .numberPad,
///     characterFilter: \.isNumber,
///     maxLength: 16,
///     transform: { text in
///         let digits = String(text.filter(\.isNumber).prefix(16))
///         return (display: cardNumberFormatted(digits), stored: digits)
///     })
/// ```
struct XenditTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var isDisabled: Bool = false
    var keyboardType: UIKeyboardType = .default
    var uiFont: UIFont? = nil
    /// Only characters for which this returns `true` are accepted on input.
    var characterFilter: ((Character) -> Bool)? = nil
    /// Maximum number of raw (pre-transform) characters allowed. Counted using
    /// `characterFilter` when set, otherwise counts all characters.
    var maxLength: Int? = nil
    /// Maps the current field text to `(display, stored)`.
    /// `display` is written back into the UITextField; `stored` is written to `text`.
    /// Called on every edit change. When `nil`, text is stored and displayed as-is.
    var transform: ((String) -> (display: String, stored: String))? = nil
    var onChanged: (() -> Void)? = nil
    var onEditingEnded: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return tf
    }

    func updateUIView(_ tf: UITextField, context: Context) {
        let display = transform?(text).display ?? text
        if tf.text != display { tf.text = display }
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: XenditComponents.appearance.resolvedPlaceholderUIColor]
        )
        tf.isEnabled = !isDisabled
        tf.isSecureTextEntry = isSecure
        tf.keyboardType = keyboardType
        tf.font = uiFont ?? .labelLgRegular
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: XenditTextField

        init(_ parent: XenditTextField) { self.parent = parent }

        func textField(
            _ tf: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if string.isEmpty { return true } // always allow deletion

            if let filter = parent.characterFilter {
                guard string.allSatisfy(filter) else { return false }
            }

            if let max = parent.maxLength {
                let currentRaw = rawCount(of: tf.text ?? "")
                let incomingRaw = parent.characterFilter.map { string.filter($0).count } ?? string.count
                return currentRaw + incomingRaw <= max
            }

            return true
        }

        @objc func textChanged(_ tf: UITextField) {
            let current = tf.text ?? ""
            let display: String
            let stored: String

            if let transform = parent.transform {
                (display, stored) = transform(current)
            } else if let max = parent.maxLength {
                let clamped: String
                if let filter = parent.characterFilter {
                    clamped = String(current.filter(filter).prefix(max))
                } else {
                    clamped = String(current.prefix(max))
                }
                (display, stored) = (clamped, clamped)
            } else {
                (display, stored) = (current, current)
            }

            if tf.text != display {
                tf.text = display
                let end = tf.endOfDocument
                tf.selectedTextRange = tf.textRange(from: end, to: end)
            }
            if parent.text != stored {
                parent.text = stored
                parent.onChanged?()
            }
        }

        func textFieldDidEndEditing(_ tf: UITextField) {
            parent.onEditingEnded?()
        }

        // MARK: - Helpers

        private func rawCount(of text: String) -> Int {
            if let filter = parent.characterFilter {
                return text.filter(filter).count
            }
            return text.count
        }
    }
}
