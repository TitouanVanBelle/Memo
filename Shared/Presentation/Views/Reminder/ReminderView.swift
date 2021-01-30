//
//  NewReminderView.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 05.01.21.
//

import Combine
import SwiftUI

struct ReminderView: View {

    @StateObject var store: ReminderStore

    @Environment(\.calendar) var calendar
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    private var isPresentingAlert: Binding<Bool> {
        Binding<Bool>(
            get: { store.alertErrorMessage != nil },
            set: { _ in store.send(event: .dismissError) }
        )
    }

    var body: some View {
        if store.shouldDismiss {
            presentationMode.wrappedValue.dismiss()
        }

        return ZStack(alignment: .top) {
            Daisy.color.primaryBackground
                .edgesIgnoringSafeArea(.all)

            GeometryReader { proxy in
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        textfield
                        if store.shouldShowEmptyTitleErrorMessage {
                            emptyTitleErrorMessage
                        }
                    }.padding(.horizontal, 28)

                    Spacer()
                    toolbar
                    bottomView
                        .frame(height: max(0, store.bottomViewHeight - proxy.safeAreaInsets.bottom))
                        .padding(.top, 10)
                }
                .padding(.top, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: isPresentingAlert) {
            Alert(title: Text("global.error".localized), message: Text(store.alertErrorMessage!))
        }
        .onAppear(perform: store.action(for: .checkNotificationAuthorization))
    }
}

// MARK: UI

fileprivate extension ReminderView {
    var textfield: some View {
        UIKitTextField(
            "reminder.textfield.placeholder".localized,
            text: $store.title,
            tag: 0,
            focusedTag: $store.focusedTag,
            onFocus: store.action(for: .clearBottomView)
        )
        .setKeyboardAppearance(UIKeyboardAppearance.default == .dark ? .light : .dark)
        .setAutocapitalizationType(.sentences)
        .setFont(Daisy.uiFont.h7)
        .setForegroundColor(Daisy.uiColor.primaryForeground)
        .accessibilityIdentifier(.reminderTitleTextfield)
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }

    var emptyTitleErrorMessage: some View {
        Text("reminder.textfield.validation_message".localized)
            .font(Daisy.font.smallBodyRegular)
            .foregroundColor(Daisy.color.error)
    }

    var toolbar: some View {
        HStack(spacing: 20) {
            calendarButton
            timeButton

            Spacer()

            createButton
        }
        .padding(.leading, 28)
        .padding(.trailing, 20)
    }

    var calendarButton: some View {
        Button(action: {
            withAnimation(.interactiveSpring(), store.action(for: .showDatePicker))
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Daisy.color.primaryForeground)

                Text(store.formattedSelectedDate)
                    .lineLimit(1)
                    .font(Daisy.font.smallBodyRegular)
                    .foregroundColor(Daisy.color.primaryForeground)
            }
        }.accessibilityIdentifier(.showDatePickerButton)
    }

    @ViewBuilder var timeButton: some View {
        Button(action: {
            withAnimation(.interactiveSpring(), store.action(for: .showTimePicker))
        }) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(store.shouldShowDateInPastErrorMessage ? Daisy.color.error : Daisy.color.primaryForeground)

                Text(store.formattedSelectedTime)
                    .lineLimit(1)
                    .font(Daisy.font.smallBodyRegular)
                    .foregroundColor(store.shouldShowDateInPastErrorMessage ? Daisy.color.error : Daisy.color.primaryForeground)
            }
        }
        .opacity(store.selectedDate == nil ? 0.3 : 1)
        .disabled(store.selectedDate == nil)
        .modifier(ShakeEffect(shakes: store.invalidAttempts))
        .accessibilityIdentifier(.showTimePickerButton)
    }

    var createButton: some View {
        Button(action: {
            withAnimation(
                .interactiveSpring(),
                store.reminder == nil ? store.action(for: .createReminder) : store.action(for: .updateReminder))
        }) {
            Text(store.reminder == nil ? "reminder.create".localized : "reminder.update".localized)
                .font(Daisy.font.smallButton)
                .foregroundColor(Daisy.color.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
        }
        .background(
            RoundedCorners(radius: 18)
                .fill(Daisy.color.tertiaryForeground)
                .shadow(color: Daisy.color.black.opacity(0.5), radius: 16, x: 0, y: 8)
        )
        .frame(height: 36)
    }

    @ViewBuilder var bottomView: some View {
        switch store.bottomViewContent {
        case .datePicker:
            CalendarView(
                interval: calendar.dateInterval(of: .year, for: Date())!,
                selectedDate: Binding(
                    get: { store.selectedDate },
                    set: { store.send(event: .selectDate($0)) }
                )
            )
            .padding(.horizontal, 20)

        case .timePicker:
            TimePicker(selectedTime: $store.selectedTime)

        case nil:
            Color.clear
        }
    }
}

