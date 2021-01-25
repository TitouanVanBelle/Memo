//
//  View+TypeErasion.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 16.01.21.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
