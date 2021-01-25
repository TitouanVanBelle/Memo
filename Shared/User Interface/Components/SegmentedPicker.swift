//
//  SegmentedPicker.swift
//  Remind
//
//  Created by Titouan Van Belle on 20.01.21.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
struct BackgroundGeometryReader: View {
    var body: some View {
        GeometryReader { geometry in
            return Color
                    .clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
}
struct SizeAwareViewModifier: ViewModifier {

    @Binding private var viewSize: CGSize

    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }

    func body(content: Content) -> some View {
        content
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if viewSize != $0 { viewSize = $0 }})
    }
}

struct SegmentedPicker<SelectionValue>: View where SelectionValue: RawRepresentable, SelectionValue.RawValue == Int {
    // Stores the size of a segment, used to create the active segment rect
    @State private var segmentSize: CGSize = .zero
    // Rounded rectangle to denote active segment
    private var activeSegmentView: AnyView {
        // Don't show the active segment until we have initialized the view
        // This is required for `.animation()` to display properly, otherwise the animation will fire on init
        let isInitialized: Bool = segmentSize != .zero
        if !isInitialized { return EmptyView().eraseToAnyView() }
        return
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Daisy.color.quartiaryForeground)
                .frame(width: segmentSize.width, height: segmentSize.height)
                .offset(x: activeSegmentHorizontalOffset)
                .animation(Animation.linear(duration: 0.1))
                .eraseToAnyView()
    }

    @Binding private var selection: SelectionValue
    private let items: [String]

    init(items: [String], selection: Binding<SelectionValue>) {
        self._selection = selection
        self.items = items
    }

    var body: some View {
        // Align the ZStack to the leading edge to make calculating offset on activeSegmentView easier
        ZStack(alignment: .leading) {
            // activeSegmentView indicates the current selection
            activeSegmentView
            HStack {
                ForEach(0..<items.count, id: \.self) { index in
                    getSegmentView(for: index)
                }
            }
        }
        .padding(4)
        .background(Daisy.color.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: UI

fileprivate extension SegmentedPicker {

    var activeSegmentHorizontalOffset: CGFloat {
        CGFloat(selection.rawValue) * (segmentSize.width + 16 / 2)
    }

    @ViewBuilder func getSegmentView(for index: Int) -> some View {
        if index >= items.count {
            EmptyView()
        }

        Text(items[index])
            .font(selection.rawValue == index ? Daisy.font.smallButton : Daisy.font.smallTitle)
            .foregroundColor(selection.rawValue == index ? Daisy.color.white: Daisy.color.primaryForeground)
            .lineLimit(1)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(minWidth: 0, maxWidth: .infinity)
            .modifier(SizeAwareViewModifier(viewSize: $segmentSize))
            .onTapGesture {
                guard index < self.items.count else {
                    return
                }

                selection = SelectionValue(rawValue: index)!
            }
    }
}


struct SegmentedPickerDark_Preview: PreviewProvider {
    @State static var meridiem: MeridiemType = .ante

    static var previews: some View {
        SegmentedPicker(items: MeridiemType.allCases.map(\.text), selection: $meridiem)
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .dark)
    }
}

struct SegmentedPickerLight_Preview: PreviewProvider {
    @State static var meridiem: MeridiemType = .post

    static var previews: some View {
        SegmentedPicker(items: MeridiemType.allCases.map(\.text), selection: $meridiem)
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .light)
    }
}
