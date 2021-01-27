//
//  TimePicker.swift
//  Remind
//
//  Created by Titouan Van Belle on 20.01.21.
//

import SwiftUI

enum MeridiemType: Int, CaseIterable {
    case ante
    case post

    var text: String {
        self == .ante ? "AM" : "PM"
    }
}

struct TimePicker: View {

    @Binding var selectedTime: Date?

    @State var meridiem: MeridiemType
    @State var hours: Int
    @State var minutes: Int

    init(selectedTime: Binding<Date?>) {
        self._selectedTime = selectedTime

        let time = selectedTime.wrappedValue ?? Date()

        let hours = Calendar.current.component(.hour, from: time)
        self._hours = State(initialValue: hours % 12)
        let minutes = Calendar.current.component(.minute, from: time)
        self._minutes = State(initialValue: minutes)
        self._meridiem = State(initialValue: hours < 12 ? MeridiemType.ante : MeridiemType.post)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack(spacing: 0) {
                    hourPicker(proxy: proxy)
                    colon
                    minutePicker(proxy: proxy)
                }

                meridianPicker
            }
        }
    }
}

fileprivate extension TimePicker {
    func hourPicker(proxy: GeometryProxy) -> some View {
        Picker(selection: Binding(
            get: { hours },
            set: { value in
                hours = value
                updateTime(with: value, component: .hour)
            }
        ), label: EmptyView()) {
            ForEach(0..<12) {
                Text($0 < 10 ? "0\($0)" : "\($0)")
                    .multilineTextAlignment(.trailing)
                    .tag($0)
                    .font(Daisy.font.h6)
                    .foregroundColor(Daisy.color.primaryForeground)
                    .padding(.leading, proxy.size.width / 2 - 30)
            }
        }
        .frame(width: proxy.size.width / 2 - 5)
        .clipped()
        .accessibilityIdentifier(.hourPicker)
    }

    var colon: some View {
        Text(":")
            .frame(width: 10, height: 32)
            .background(Color.white.opacity(0.1))
            .font(Daisy.font.h6)
            .foregroundColor(Daisy.color.primaryForeground)
    }

    func minutePicker(proxy: GeometryProxy) -> some View {
        Picker(selection: Binding(
            get: { minutes },
            set: { value in
                minutes = value
                updateTime(with: value, component: .minute)
            }
        ), label: EmptyView()) {
            ForEach(0..<60) {
                Text($0 < 10 ? "0\($0)" : "\($0)")
                    .multilineTextAlignment(.leading)
                    .tag($0)
                    .font(Daisy.font.h6)
                    .foregroundColor(Daisy.color.primaryForeground)
                    .padding(.trailing, proxy.size.width / 2 - 32)
            }
        }
        .frame(width: proxy.size.width / 2 - 5)
        .clipped()
        .accessibilityIdentifier(.minutePicker)
    }

    func updateTime(with value: Int, component: Calendar.Component) {
        var components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime ?? Date())
        if component == .minute {
            components.minute = value
        } else if component == .hour {
            components.hour = value + (meridiem == .ante ? 0 : 12)
        }
        selectedTime = Calendar.current.date(from: components)!
    }

    var meridianPicker: some View {
        SegmentedPicker(
            items: MeridiemType.allCases.map(\.text),
            selection: Binding(
                get: { meridiem },
                set: {
                    meridiem = $0
                    var components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime ?? Date())
                    if meridiem == .ante && components.hour! > 11 {
                        components.hour! -= 12
                    } else if meridiem == .post && components.hour! < 12 {
                        components.hour! += 12
                    }

                    selectedTime = Calendar.current.date(from: components)!
                }
            )
        )
        .frame(width: 140)
    }
}

struct TimePickerDark_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(selectedTime: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .dark)
    }
}

struct TimePickerLight_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(selectedTime: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .light)
    }
}
