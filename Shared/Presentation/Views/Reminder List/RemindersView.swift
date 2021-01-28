//
//  RemindersView.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 28.01.21.
//

import SwiftUI

struct RemindersView: View {

    @ObservedObject var store: RemindersStore

    let viewFactory: ViewFactory

    init(store: RemindersStore, viewFactory: ViewFactory) {
        self.store = store
        self.viewFactory = viewFactory
    }

    var body: some View {
        ZStack(alignment: .top) {
            Daisy.color.primaryBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                reminderList
                    .padding(.horizontal, 28)
                    .padding(.top, 40)
            }
        }
        .onAppear(perform: store.action(for: .loadReminders))
        .sheet(isPresented: $store.isSheetPresented) {
            viewFactory.makeReminderView(for: store.selectedReminder)
        }
    }
}

fileprivate extension RemindersView {
    var reminderList: some View {
        ReminderList(
            sections: store.reminders,
            shouldShowSectionTitles: true,
            onToggle: { withAnimation(.interactiveSpring(), store.action(for: .toggleReminder($0))) },
            onDelete: { withAnimation(.interactiveSpring(), store.action(for: .deleteReminder($0, $1))) },
            onTap: { store.send(event: .selectReminder($0)) }
        )
    }
}
