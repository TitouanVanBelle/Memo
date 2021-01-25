//
//  UIKitTextField.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 14.01.21.
//

import SwiftUI
import Combine

struct UIKitTextField: UIViewRepresentable {
    let tag: Int
    let placeholder: String
    let onFocus: (() -> Void)?

    @Binding var text: String
    @Binding var focusedTag: Int

    class MutatingWrapper {
        var keyboardType: UIKeyboardType = .default
        var returnKeyType: UIReturnKeyType = .next
        var autocapitalizationType: UITextAutocapitalizationType = .none
        var keyboardAppearance: UIKeyboardAppearance = .dark
        var font: UIFont = .systemFont(ofSize: 15)
        var foregroundColor: UIColor = .black
    }

    var mutatingWrapper = MutatingWrapper()

    var shouldBeFirstResponder: Bool {
        focusedTag == tag
    }

    init(
        _ placeholder: String = "",
        text: Binding<String>,
        tag: Int,
        focusedTag: Binding<Int>,
        onFocus: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.tag = tag
        self._focusedTag = focusedTag
        self.onFocus = onFocus
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.tag = tag
        textField.text = text
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.placeholder = placeholder

        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textFieldDidChange(_:)), for: .editingChanged)

        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        textField.returnKeyType = mutatingWrapper.returnKeyType
        textField.keyboardType = mutatingWrapper.keyboardType
        textField.autocapitalizationType = mutatingWrapper.autocapitalizationType
        textField.keyboardAppearance = mutatingWrapper.keyboardAppearance
        textField.font = mutatingWrapper.font
        textField.textColor = mutatingWrapper.foregroundColor

        if shouldBeFirstResponder {
            if !context.coordinator.didBecomeFirstResponder {
                context.coordinator.didBecomeFirstResponder = true
                DispatchQueue.main.async {
                    textField.becomeFirstResponder()
                }
            }
        } else {
            if context.coordinator.didBecomeFirstResponder {
                context.coordinator.didBecomeFirstResponder = false
                DispatchQueue.main.async {
                    textField.resignFirstResponder()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, tag: tag, focusedTag: $focusedTag, onFocus: onFocus)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let tag: Int
        var didBecomeFirstResponder = false
        let onFocus: (() -> Void)?

        @Binding var text: String
        @Binding var focusedTag: Int

        init(
            text: Binding<String>,
            tag: Int,
            focusedTag: Binding<Int>,
            onFocus: (() -> Void)?
        ) {
            self._text = text
            self.tag = tag
            self._focusedTag = focusedTag
            self.onFocus = onFocus
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                withAnimation {
                    self.focusedTag = self.tag
                    self.onFocus?()
                }
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            self.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            false
        }
    }
}

extension UIKitTextField {
    func setKeyboardType(_ keyboardType: UIKeyboardType) -> Self {
        mutatingWrapper.keyboardType = keyboardType
        return self
    }

    func setReturnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        mutatingWrapper.returnKeyType = returnKeyType
        return self
    }

    func setAutocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        mutatingWrapper.autocapitalizationType = autocapitalizationType
        return self
    }

    func setKeyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        mutatingWrapper.keyboardAppearance = keyboardAppearance
        return self
    }

    func setFont(_ font: UIFont) -> Self {
        mutatingWrapper.font = font
        return self
    }

    func setForegroundColor(_ foregroundColor: UIColor) -> Self {
        mutatingWrapper.foregroundColor = foregroundColor
        return self
    }
}
