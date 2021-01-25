//
//  AppView.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 11.01.21.
//

import Typist
import SwiftUI

struct AppView: View {

    let viewFactory: ViewFactory

    @AppStorage("needsOnboarding")
    var needsOnboarding: Bool = true

    var body: some View {
        ZStack {
            if needsOnboarding {
                onboarding
            } else {
                app
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5))
    }
}

// MARK: Helpers

fileprivate extension AppView {
    var app: some View {
        viewFactory.makeTodayView()
    }

    var onboarding: some View {
        OnboardingView(needsOnboarding: $needsOnboarding)
    }
}
