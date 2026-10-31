//
//  CheckoutHeroUITests.swift
//  CheckoutHeroUITests
//
//  End-to-end smoke test of the main flow an App Reviewer will exercise.
//

import XCTest

final class CheckoutHeroUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // In-memory store + fixed language/locale so labels and currency formatting are stable.
        app.launchArguments = ["-UITesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    @MainActor
    func testEmptyStateIsShownOnFirstLaunch() {
        XCTAssertTrue(app.staticTexts["No Shopping Lists"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCreateListAddItemCheckAndDelete() {
        // 1. Create a list
        app.buttons["addListButton"].tap()
        let nameField = app.textFields["listNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Groceries")
        app.buttons["saveListButton"].tap()

        let listRow = app.staticTexts["Groceries"]
        XCTAssertTrue(listRow.waitForExistence(timeout: 5), "New list should appear")

        // 2. Open it and see the empty items state
        listRow.tap()
        XCTAssertTrue(app.staticTexts["No Items Yet"].waitForExistence(timeout: 5))

        // 3. Add an item: Milk, 2 × 1.50
        app.buttons["addItemButton"].tap()
        let itemName = app.textFields["itemNameField"]
        XCTAssertTrue(itemName.waitForExistence(timeout: 5))
        itemName.tap()
        itemName.typeText("Milk")
        replaceText(in: app.textFields["itemQuantityField"], with: "2")
        replaceText(in: app.textFields["itemPriceField"], with: "1.50")
        app.buttons["confirmAddItemButton"].tap()

        // 4. Item and total are shown
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 5), "Item should appear")
        let total = app.staticTexts["totalAmountLabel"]
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        XCTAssertEqual(total.label, "$3.00")

        // 5. Check the item off
        let toggle = app.buttons["toggleItemButton"].firstMatch
        XCTAssertTrue(toggle.label.lowercased().hasSuffix("unchecked"), "got \(toggle.label)")
        toggle.tap()
        XCTAssertTrue(toggle.label.lowercased().hasSuffix(", checked"), "got \(toggle.label)")

        // 6. Delete it via swipe + confirmation alert
        let row = app.cells.containing(.staticText, identifier: "Milk").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeLeft()
        let swipeDelete = app.buttons.matching(NSPredicate(format: "label == %@", "Delete")).firstMatch
        XCTAssertTrue(swipeDelete.waitForExistence(timeout: 5), "Swipe should reveal Delete")
        swipeDelete.tap()
        let alert = app.alerts["Delete Item"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["No Items Yet"].waitForExistence(timeout: 5), "List should be empty again")
        XCTAssertEqual(total.label, "$0.00")
    }

    @MainActor
    func testAppLaunchesToForeground() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.navigationBars["Shopping Lists"].waitForExistence(timeout: 5))
    }

    /// The app is free: Settings must not offer tips or any purchase.
    @MainActor
    func testSettingsHasNoPurchasesAndNoRawKeys() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["remindersImportRow"].waitForExistence(timeout: 5))

        for word in ["Tip", "Support CheckoutHero", "Purchase", "Buy"] {
            let matches = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", word))
            XCTAssertEqual(matches.count, 0, "Unexpected '\(word)' in Settings: \(matches.allElementsBoundByIndex.map(\.label))")
        }
        assertNoRawLocalizationKeys()
    }

    /// Settings → Import from Reminders must ask for permission, not crash.
    /// (iOS 17+ terminates the app if NSRemindersFullAccessUsageDescription is missing.)
    @MainActor
    func testRemindersImportAsksPermissionWithoutCrashing() {
        // With no lists yet, the importer explains what to do instead of showing a blank screen.
        app.buttons["settingsButton"].tap()
        let row = app.buttons["remindersImportRow"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
        XCTAssertTrue(app.staticTexts["Create a List First"].waitForExistence(timeout: 5), "Empty state should explain next step")
        assertNoRawLocalizationKeys()
        app.buttons["Cancel"].firstMatch.tap()
        app.buttons["Done"].firstMatch.tap()

        // Create a list, then import into it: this triggers the Reminders permission request.
        app.buttons["addListButton"].tap()
        let nameField = app.textFields["listNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Groceries")
        app.buttons["saveListButton"].tap()
        XCTAssertTrue(app.staticTexts["Groceries"].waitForExistence(timeout: 5))

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
        // "Groceries" exists both in the picker sheet and in the list behind it; tap the visible one.
        XCTAssertTrue(app.navigationBars["Import from Reminders"].waitForExistence(timeout: 5))
        let candidates = app.buttons.containing(.staticText, identifier: "Groceries")
        let deadline = Date().addingTimeInterval(5)
        var listInPicker: XCUIElement?
        while listInPicker == nil && Date() < deadline {
            listInPicker = candidates.allElementsBoundByIndex.first { $0.isHittable }
        }
        guard let listInPicker else { return XCTFail("List not tappable in Reminders picker") }
        listInPicker.tap()

        // Permission prompt is shown by SpringBoard, not the app.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Reminders permission prompt should appear")
        let deny = alert.buttons.matching(NSPredicate(format: "label IN %@", ["Don’t Allow", "Don't Allow"])).firstMatch
        (deny.exists ? deny : alert.buttons.element(boundBy: 0)).tap()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App must still be running after the Reminders request")
        XCTAssertTrue(app.staticTexts["Reminders Access Denied"].waitForExistence(timeout: 5), "Denied state should be explained")
        assertNoRawLocalizationKeys()
    }

    // MARK: - Helpers

    /// Fails if any visible text looks like an untranslated key, e.g. "no_lists_title".
    private func assertNoRawLocalizationKeys(file: StaticString = #filePath, line: UInt = #line) {
        let rawKeys = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "^[a-z]+(_[a-z]+)+$"))
        XCTAssertEqual(rawKeys.count, 0, "Raw keys on screen: \(rawKeys.allElementsBoundByIndex.map(\.label))", file: file, line: line)
    }

    private func replaceText(in field: XCUIElement, with text: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        let current = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        field.typeText(text)
    }
}
