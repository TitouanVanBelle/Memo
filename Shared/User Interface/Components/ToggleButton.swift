//
//  CompletedButton.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 10.01.21.
//

import SwiftUI

struct ToggleButton: View {

    @State var completed: Bool

    let onToggle: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.interactiveSpring()) {
                completed.toggle()
            }

            onToggle()
        }) {
            image
        }
        .background(background)
    }
}

// MARK: UI

fileprivate extension ToggleButton {
    var foregroundColor: Color {
        completed ? Daisy.color.white : .clear
    }

    var backgroundColor: Color {
        completed ? Daisy.color.tertiaryForeground : .clear
    }

    var strokeColor: Color {
        completed ? Daisy.color.tertiaryForeground : Daisy.color.secondaryForeground
    }

    var background: some View {
        Circle()
            .strokeBorder(strokeColor, lineWidth: 2)
            .background(
                Circle()
                    .fill(backgroundColor)
            )
    }

    var image: some View {
        Image("Check")
            .resizable()
            .frame(width: 12, height: 12)
            .padding(6)
            .foregroundColor(foregroundColor)
    }
}

struct ToggleButtonOffDark_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(completed: false, onToggle: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Daisy.color.secondaryBackground)
            .environment(\.colorScheme, .dark)
    }
}


struct ToggleButtonOnDark_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(completed: true, onToggle: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Daisy.color.secondaryBackground)
            .environment(\.colorScheme, .dark)
    }
}

struct ToggleButtonOffLight_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(completed: false, onToggle: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Daisy.color.secondaryBackground)
            .environment(\.colorScheme, .light)
    }
}


struct ToggleButtonOnLight_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(completed: true, onToggle: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Daisy.color.secondaryBackground)
            .environment(\.colorScheme, .light)
    }
}
