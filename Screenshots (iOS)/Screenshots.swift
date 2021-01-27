//
//  Screenshots.swift
//  Screenshots
//
//  Created by Titouan Van Belle on 25.01.21.
//

import XCTest

fileprivate extension XCUIElementQuery {
    subscript(identifier: AccessibilityIdentifier) -> XCUIElement {
        self[identifier.rawValue]
    }
}

func localizedString(key: String) -> String {
    let testBundle = Bundle(for: Screenshots.self)
    let path = testBundle.path(forResource: deviceLanguage, ofType: "lproj") ?? testBundle.path(forResource: String(deviceLanguage.split(separator: "-").first!), ofType: "lproj")!
    let localizationBundle = Bundle(path: path)
    let result = NSLocalizedString(key, bundle:localizationBundle!, comment: "") //
    return result
}

class Screenshots: XCTestCase {

    func wait(seconds: Double) {
        let expect = expectation(description: "Pause Expectation")
        DispatchQueue.init(label: "Pause Queue").asyncAfter(deadline: .now() + seconds) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: seconds * 2)
    }

    override func setUpWithError() throws {
        let app = XCUIApplication()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launchArguments = ["-setupAppForScreenshotTarget"]
        app.launch()

        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            alert.buttons["Allow"].tap()
            return true
        }
    }

    func testSnapshots() throws {
        let app = XCUIApplication()

        snapshot("0Launch")

        app.buttons[.getStartedButton].tap()
        snapshot("1Today")

        app.buttons[.createReminderButton].tap()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let allowBtn = springboard.buttons["Allow"]
        if allowBtn.waitForExistence(timeout: 2) {
            allowBtn.tap()
        }

        app.textFields[.reminderTitleTextfield].tap()

        wait(seconds: 1)

        snapshot("2NewReminder-Empty")

        app.textFields[.reminderTitleTextfield].typeText(localizedString(key: "seed.new.title"))

        app.buttons[.showDatePickerButton].tap()
        snapshot("3NewReminder-DatePicker")
        app.buttons["today"].tap()

        app.buttons[.showTimePickerButton].tap()
        snapshot("4NewReminder-TimePicker")

        let currentHour = app.pickers[.hourPicker].pickerWheels.firstMatch.value as! String
        let nextHour = Int(currentHour)! == 11 ? 10 : Int(currentHour)! + 1
        let nextHourString = nextHour < 10 ? "0\(nextHour)" : "\(nextHour)"
        app.pickers[.hourPicker].pickerWheels.firstMatch.adjust(toPickerWheelValue: nextHourString)

        wait(seconds: 1)

        app.pickers[.minutePicker].pickerWheels.firstMatch.adjust(toPickerWheelValue: "00")

        wait(seconds: 1)

        app.textFields[.reminderTitleTextfield].tap()

        wait(seconds: 1)

        snapshot("5NewReminder-Complete")

    }
}
