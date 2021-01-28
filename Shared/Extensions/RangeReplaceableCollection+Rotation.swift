//
//  RangeReplacableCollection+Rotation.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 28.01.21.
//

import Foundation

extension RangeReplaceableCollection {
    func rotatedRight() -> SubSequence {
        let index = self.index(endIndex, offsetBy: -1, limitedBy: startIndex) ?? startIndex
        return self[index...] + self[..<index]
    }

    func rotatedLeft() -> SubSequence {
        let index = self.index(startIndex, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        return self[index...] + self[..<index]

    }
}
