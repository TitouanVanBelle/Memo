//
//  ReminderCell.swift
//  Remind
//
//  Created by Titouan Van Belle on 04.01.21.
//

import SwiftUI

struct ReminderCell: View {

    @State private var offset = CGSize.zero
    @State var scale : CGFloat = 0.5
    @State var opacity : Double = .zero

    let reminder: Reminder
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            backgroundView
            foregroundView
                .offset(offset)
                .animation(.interactiveSpring())
                .gesture(DragGesture()
                            .onChanged { gesture in
                                let width = gesture.translation.width
                                offset.width = min(0, width)
                                scale = 0.5 + 0.5 * min(abs(width), 50) / 50

                                if offset.width < -20 {
                                    opacity = Double(min(abs(offset.width), 50) / 50)
                                } else {
                                    opacity = 0
                                }
                            }
                            .onEnded { _ in
                                if offset.width < -50 {
                                    scale = 1
                                    opacity = 1
                                    offset.width = -60
                                } else {
                                    opacity = 0
                                    scale = 0.5
                                    offset = .zero
                                }
                            }
                )
        }
        .transition(.identity)
    }
}

// MARK: UI

fileprivate extension ReminderCell {

    var backgroundView: some View {
        HStack {
            Spacer()
            deleteButton
        }
        .padding(.trailing, 16)
    }

    var foregroundView: some View {
        HStack(spacing: 16) {
            toggleButton
            VStack(alignment: .leading, spacing: 2) {
                title
                if reminder.date != nil || reminder.time != nil {
                    subtitle
                }
            }

        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 24)
        .padding(16)
        .background(
            RoundedCorners(radius: 12)
                .fill(Daisy.color.secondaryBackground)
        )
        .opacity(reminder.isCompleted ? 0.5 : 1.0)
    }

    var title: some View {
        Text("\(reminder.title)")
            .font(Daisy.font.largeBody)
            .foregroundColor(Daisy.color.primaryForeground)
    }

    var subtitle: some View {
        HStack(spacing: 2) {
            if reminder.date != nil {
                Text(DateFormatter.relativeDateFormatter.string(from: reminder.date!))
            }
            if reminder.time != nil {
                Text("\("reminder_cell.at".localized) \(DateFormatter.timeWithMeridian.string(from: reminder.time!))")
            }
        }
        .font(Daisy.font.smallBody)
        .foregroundColor(foregroundColorForSubtitle(for: reminder))
    }

    func foregroundColorForSubtitle(for reminder: Reminder) -> Color {
        if reminder.time != nil {
            return reminder.combinedDateAndTime! < Date() ? Daisy.color.error : Daisy.color.quartiaryForeground
        } else if let date = reminder.date {
            return date.isBeforeToday ? Daisy.color.error : Daisy.color.quartiaryForeground
        }

        return Color.clear
    }

    var toggleButton: some View {
        ToggleButton(completed: reminder.isCompleted, onToggle: onToggle)
    }

    var deleteButton: some View {
        Button(action: {
            onDelete()
        }) {
            Image(systemName: "trash")
                .font(Daisy.font.smallButton)
                .foregroundColor(Daisy.color.primaryForeground)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
}

struct ReminderCellDark_Previews: PreviewProvider {
    static let reminder: Reminder = {
        let reminder = Reminder(context: PersistenceController.shared.container.viewContext)
        reminder.title = "Take pills"
        reminder.date = Date()
        reminder.time = Date()
        reminder.isCompleted = true
        return reminder
    }()

    static var previews: some View {
        ReminderCell(
            reminder: reminder,
            onToggle: {},
            onDelete: {}
        )
        .previewLayout(.fixed(width: 395, height: 76))
        .padding()
        .background(Daisy.color.primaryBackground)
        .environment(\.colorScheme, .dark)
    }
}

struct ReminderCellLight_Previews: PreviewProvider {
    static let reminder: Reminder = {
        let reminder = Reminder(context: PersistenceController.shared.container.viewContext)
        reminder.title = "Take pills"
        reminder.date = Date()
        reminder.time = Date()
        reminder.isCompleted = true
        return reminder
    }()

    static var previews: some View {
        ReminderCell(
            reminder: reminder,
            onToggle: {},
            onDelete: {}
        )
        .previewLayout(.fixed(width: 395, height: 76))
        .padding()
        .environment(\.colorScheme, .light)
        .background(Daisy.color.primaryBackground)
    }
}
