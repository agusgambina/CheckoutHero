# Google Apps Script — Receipt Sync Setup

CheckoutHero syncs receipts to a Google Sheet through a free Google Apps Script Web App (no Google Cloud SDK, no billing, no server hosting).

## 1. Create the destination sheet

1. Open <https://sheets.new> to create a new Google Sheet.
2. Rename it (e.g. `CheckoutHero Receipts`).
3. In row 1, put headers:
   `Timestamp | Date | Store | Total | Currency`

## 2. Add the Apps Script

1. In the Sheet, choose **Extensions → Apps Script**.
2. Delete the placeholder `myFunction()` code and paste the script below.
3. Save (⌘S) and name the project (e.g. `CheckoutHero Receipt Sync`).

```javascript
function doPost(e) {
  try {
    var payload = JSON.parse(e.postData.contents);

    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
    sheet.appendRow([
      new Date(),
      payload.date || '',
      payload.store || '',
      payload.total || '',
      payload.currencySymbol || ''
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ status: 'ok' }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'error', message: error.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

## 3. Deploy as a Web App

1. Click **Deploy → New deployment**.
2. Under **Select type**, pick the gear icon → **Web app**.
3. Configure:
   - **Description:** `CheckoutHero receipt sync`
   - **Execute as:** `Me`
   - **Who has access:** `Anyone` (required — the iOS app posts without a Google login)
4. Click **Deploy**, authorize when prompted, and copy the **Web app URL** (looks like `https://script.google.com/macros/s/AKfycb.../exec`).

## 4. Wire the URL into the app

Open `CheckoutHero/Services/ServicesGoogleSheetsSyncService.swift` and paste your URL:

```swift
static let webAppURL: String = "https://script.google.com/macros/s/AKfycb.../exec"
```

Rebuild and run — receipts should appear in the Sheet within a second or two of tapping **Sync to Sheets**.

## Notes

- Every time you edit the script, click **Deploy → Manage deployments → pencil icon → New version** to publish changes. Existing URL stays the same.
- Access is `Anyone` but the URL is unguessable; treat it like a password. Rotate by creating a new deployment if needed.
- The Sheet's first tab is written to. If you rename or reorder tabs, adjust `getSheets()[0]` accordingly.
