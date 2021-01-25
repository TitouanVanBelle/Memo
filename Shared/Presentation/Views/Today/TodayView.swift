//
//  ContentView.swift
//  Shared
//
//  Created by Titouan Van Belle on 04.01.21.
//

import Combine
import SwiftUI
import CoreData

struct TodayView: View {

    @ObservedObject var store: TodayStore

    let viewFactory: ViewFactory

    private var isPresentingAlert: Binding<Bool> {
        Binding<Bool>(
            get: { store.alertErrorMessage != nil },
            set: { _ in store.send(event: .dismissError) }
        )
    }

    init(store: TodayStore, viewFactory: ViewFactory) {
        self.store = store
        self.viewFactory = viewFactory
    }

    var body: some View {
        #if os(macOS)
          view
            .frame(minWidth: 400, minHeight: 600)
        #else
            view
        #endif
    }
}

fileprivate extension TodayView {
    var view: some View {
        ZStack(alignment: .top) {
            Daisy.color.primaryBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    header
                    reminders
                    Color.clear
                        .frame(height: 70)
                }
                .padding(.horizontal, 28)
                .padding(.top, 40)
            }

            if store.reminders.isEmpty {
                GeometryReader { proxy in
                    emptyView
                        .frame(width: 2 * proxy.size.width / 3)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
            }

            VStack {
                Spacer()
                createReminderButton
            }

        }
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: store.action(for: .loadReminders))
        .alert(isPresented: isPresentingAlert) {
            Alert(title: Text("Error"), message: Text(store.alertErrorMessage!))
        }
        .sheet(isPresented: $store.isSheetPresented) {
            reminderView
        }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Date().formatted(using: .full))
                    .font(Daisy.font.largeTitle)
                    .foregroundColor(Daisy.color.quartiaryForeground)

                Text("Hello 👋")
                    .font(Daisy.font.h1)
                    .foregroundColor(Daisy.color.primaryForeground)

                Text("You have \(store.reminders.count) reminders today")
                    .lineLimit(2)
                    .font(Daisy.font.largeTitle)
                    .foregroundColor(Daisy.color.secondaryForeground)
            }

            Spacer()
        }
    }

    var reminders: some View {
        RemindersList(
            reminders: store.reminders,
            onToggle: { withAnimation(.interactiveSpring(), store.action(for: .toggleReminder($0))) },
            onDelete: { withAnimation(.interactiveSpring(), store.action(for: .deleteReminder($0))) },
            onTap: { store.send(event: .selectReminder($0)) }
        )
    }

    var emptyView: some View {
        VStack(spacing: 30) {
            Image("NoReminders")
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(spacing: 6) {
                Text("No Reminders")
                    .font(Daisy.font.largeTitle)
                    .foregroundColor(Daisy.color.primaryForeground)

                Text("Create reminders by hitting\nthe blue button below")
                    .font(Daisy.font.largeBody)
                    .foregroundColor(Daisy.color.secondaryForeground)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var createReminderButton: some View {
        Button(action: { store.send(event: .createNewReminder) }) {
            Text("Create Reminder")
                .font(Daisy.font.smallButton)
                .foregroundColor(Daisy.color.white)
                .padding(.horizontal, 32)
        }
        .background(
            RoundedCorners(radius: 24)
                .fill(Daisy.color.tertiaryForeground)
                .frame(height: 48)
                .shadow(color: Daisy.color.black.opacity(0.5), radius: 16, x: 0, y: 8)
        )
        .padding(.bottom, 28)
    }

    var reminderView: some View {
        viewFactory.makeReminderView(for: store.selectedReminder)
    }
}
