//
//  RemindersView.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 28.01.21.
//

import SwiftUI

struct RemindersView: View {

    @StateObject var store: RemindersStore

    let viewFactory: ViewFactory

    var body: some View {
        ZStack(alignment: .top) {
            Daisy.color.primaryBackground
                .edgesIgnoringSafeArea(.all)

            if store.reminders.isEmpty {
                GeometryReader { proxy in
                    emptyView
                        .frame(width: 2 * proxy.size.width / 3)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    reminderList
                        .padding(.horizontal, 28)
                        .padding(.top, 40)
                }
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

    var emptyView: some View {
        VStack(spacing: 30) {
            Image("NoReminders")
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(spacing: 6) {
                Text("today.empty_view.title".localized)
                    .font(Daisy.font.largeTitle)
                    .foregroundColor(Daisy.color.primaryForeground)
            }
        }
    }
}
