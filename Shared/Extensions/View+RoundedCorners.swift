//
//  View+RoundedCorners.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 05.01.21.
//

import SwiftUI


struct Corner: OptionSet {
    let rawValue: Int

    static let topRight = Corner(rawValue: 1 << 0)
    static let topLeft = Corner(rawValue: 1 << 1)
    static let bottomRight = Corner(rawValue: 1 << 2)
    static let bottomLeft = Corner(rawValue: 1 << 3)

    static let all: Corner = [.topRight, .topLeft, .bottomRight, .bottomLeft]
    static let top: Corner = [.topRight, .topLeft]
    static let bottom: Corner = [.bottomRight, .bottomLeft]
    static let right: Corner = [.topRight, .bottomRight]
    static let left: Corner = [.topLeft, .bottomLeft]
}

struct RoundedCorners: Shape {
    var radius: CGFloat = .zero
    var corners: Corner = .all

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        func cornerRadius(for corner: Corner) -> CGFloat {
            let cornerRadius = corners.contains(corner) ? radius : .zero
            return min(min(cornerRadius, height / 2), width / 2)
        }

        // Make sure we do not exceed the size of the rectangle
        let tr = cornerRadius(for: .topRight)
        let tl = cornerRadius(for: .topLeft)
        let bl = cornerRadius(for: .bottomLeft)
        let br = cornerRadius(for: .bottomRight)

        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - tr, y: 0))
        path.addArc(center: CGPoint(x: width - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - br))
        path.addArc(center: CGPoint(x: width - br, y: height - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: height))
        path.addArc(center: CGPoint(x: bl, y: height - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
