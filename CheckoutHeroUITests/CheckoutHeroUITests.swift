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

    /// The path App Review takes: Settings → Support CheckoutHero.
    /// Uses the scheme's StoreKit.storekit configuration.
    @MainActor
    func testTipJarShowsAllTipsWithRealText() {
        app.buttons["settingsButton"].tap()
        let tipRow = app.buttons["tipJarRow"]
        XCTAssertTrue(tipRow.waitForExistence(timeout: 5))
        tipRow.tap()

        for id in ["tip_small", "tip_medium", "tip_large"] {
            XCTAssertTrue(app.buttons["tip_\(id)"].waitForExistence(timeout: 15), "\(id) should be listed")
        }

        // No untranslated localization keys anywhere on the screen
        let rawKeys = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "^[a-z]+(_[a-z]+)+$"))
        XCTAssertEqual(rawKeys.count, 0, "Raw keys on screen: \(rawKeys.allElementsBoundByIndex.map(\.label))")

        app.buttons["tipJarDoneButton"].tap()
        XCTAssertFalse(app.buttons["tip_tip_small"].waitForExistence(timeout: 2), "Done should close the Tip Jar")
    }

    // MARK: - Helpers

    private func replaceText(in field: XCUIElement, with text: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        let current = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        field.typeText(text)
    }
}
