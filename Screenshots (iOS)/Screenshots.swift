//
//  Screenshots.swift
//  Screenshots
//
//  Created by Titouan Van Belle on 25.01.21.
//

import XCTest

class Screenshots: XCTestCase {

    override func setUpWithError() throws {
        let app = XCUIApplication()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    func testExample() throws {
        snapshot("0Launch")
    }
}
