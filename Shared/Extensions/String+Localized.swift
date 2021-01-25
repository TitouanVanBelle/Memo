//
//  String+Localized.swift
//  Yoda
//
//  Created by Titouan Van Belle on 19.01.21.
//

import Foundation


extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
