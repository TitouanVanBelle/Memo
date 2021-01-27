//
//  View+AccessibilityIdentifiers.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import SwiftUI

extension View {
    func accessibilityIdentifier(_ identifier: AccessibilityIdentifier) -> some View {
        accessibility(identifier: identifier.rawValue)
    }
}
