//
//  ScreenshotTests.swift
//  CheckoutHeroUITests
//
//  Generates App Store screenshots. Skipped during normal test runs; run via
//  scripts/screenshots.sh, which sets SCREENSHOTS_DIR and SCREENSHOT_LANG.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!
    private var outputDir: URL!
    private var language = "en"

    override func setUpWithError() throws {
        let env = ProcessInfo.processInfo.environment
        guard let dir = env["SCREENSHOTS_DIR"], !dir.isEmpty else {
            throw XCTSkip("Set SCREENSHOTS_DIR (scripts/screenshots.sh) to generate App Store screenshots")
        }
        language = env["SCREENSHOT_LANG"] ?? "en"
        outputDir = URL(fileURLWithPath: dir)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        continueAfterFailure = false
        app = XCUIApplication()
        let locale = language == "es" ? "es_ES" : "en_US"
        app.launchArguments = [
            "-UITesting", "-ScreenshotData",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale,
            "-selected_language", "system",
        ]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        let firstList = language == "es" ? "Compras de la Semana" : "Weekly Groceries"

        // 1. All lists
        XCTAssertTrue(app.staticTexts[firstList].waitForExistence(timeout: 10))
        settle()
        snap("01-lists")

        // 2. A list in progress, with running total
        app.staticTexts[firstList].tap()
        XCTAssertTrue(app.staticTexts["totalAmountLabel"].waitForExistence(timeout: 5))
        settle()
        snap("02-list-detail")

        // 3. Adding an item, with the total preview filled in
        app.buttons["addItemButton"].tap()
        let name = app.textFields["itemNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText(language == "es" ? "Aguacates" : "Avocados")
        replaceText(in: app.textFields["itemQuantityField"], with: "3")
        // On smaller iPhones the keyboard covers the price field.
        dismissKeyboard()
        replaceText(in: app.textFields["itemPriceField"], with: language == "es" ? "1,25" : "1.25")
        // Dismiss the keyboard so the whole form is visible.
        dismissKeyboard()
        snap("03-add-item")
        app.buttons["confirmAddItemButton"].tap()

        // 4. Receipts (scanning itself needs a camera, which the simulator does not have)
        app.navigationBars.buttons.element(boundBy: 0).tap() // back to lists
        app.buttons[language == "es" ? "Recibos" : "Receipts"].firstMatch.tap()
        let firstReceipt = language == "es" ? "Mercado La Cesta Verde" : "Green Basket Market"
        XCTAssertTrue(app.staticTexts[firstReceipt].waitForExistence(timeout: 5))
        settle()
        snap("04-receipts")

        // 5. Settings
        app.buttons[language == "es" ? "Listas" : "Lists"].firstMatch.tap()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout: 5))
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["remindersImportRow"].waitForExistence(timeout: 5))
        settle()
        snap("05-settings")
    }

    // MARK: - Helpers

    private func settle() {
        // Let animations, the keyboard and scroll indicators finish.
        Thread.sleep(forTimeInterval: 1.2)
    }

    private func snap(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let url = outputDir.appendingPathComponent("\(name).png")
        do {
            try screenshot.pngRepresentation.write(to: url)
        } catch {
            XCTFail("Could not write \(url.path): \(error)")
        }
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func dismissKeyboard() {
        let done = app.toolbars.buttons.element(boundBy: app.toolbars.buttons.count > 0 ? app.toolbars.buttons.count - 1 : 0)
        if done.exists { done.tap() }
        settle()
    }

    private func replaceText(in field: XCUIElement, with text: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        // On iPad the form can still be scrolling when the first tap lands, so retry
        // until the field actually has keyboard focus.
        for _ in 0..<3 {
            field.tap()
            if (field.value(forKey: "hasKeyboardFocus") as? Bool) == true { break }
            settle()
        }
        let current = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        field.typeText(text)
    }
}
