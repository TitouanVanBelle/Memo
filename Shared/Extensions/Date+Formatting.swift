//
//  Date+Formatting.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 04.01.21.
//

import Foundation

extension Date {
    func formatted(using formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
}
