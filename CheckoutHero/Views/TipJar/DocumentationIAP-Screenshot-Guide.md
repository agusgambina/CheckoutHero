# 📸 Taking Perfect IAP Screenshots

## Quick Instructions

### 1. Prepare Your Simulator

**Best Device for Screenshots:**
- iPhone 15 Pro or iPhone 15 Pro Max
- These produce high-quality screenshots that Apple accepts

**Set Up Appearance:**
```
1. Open Simulator
2. Features → Appearance → Light (or Dark, your preference)
3. Make sure status bar looks clean (full battery, good signal)
```

### 2. Configure Your Scheme (If Not Done Already)

```
1. Xcode: Product → Scheme → Edit Scheme...
2. Run → Options tab
3. StoreKit Configuration → Select "StoreKit.storekit"
4. Close
```

### 3. Run the App

```
1. Build and run (⌘R)
2. Wait for app to launch
3. Navigate to: Settings → Support CheckoutHero (or wherever you placed Tip Jar)
```

### 4. Take the Screenshot

**Method 1: Using Simulator Menu**
```
1. File → New Screen Shot (⌘S)
2. Screenshot saves to Desktop
```

**Method 2: Using Screenshot Tool**
```
1. Cmd+Shift+5 to open macOS screenshot tool
2. Click "Capture Selected Window"
3. Click on simulator window
```

### 5. Verify Screenshot Quality

Your screenshot should show:
- ✅ Clear, unobscured view of the Tip Jar
- ✅ All three tip options visible
- ✅ Prices displayed correctly
- ✅ Icons and descriptions readable
- ✅ Clean status bar (optional but preferred)

---

## Pro Tips for Better Screenshots

### Option 1: Use Light Mode
Light mode screenshots tend to look cleaner and more professional.

```swift
// Force light mode for screenshots (temporary)
// In YourApp.swift or View:
.preferredColorScheme(.light)
```

### Option 2: Hide Development Elements

If you have any debug UI, make sure it's hidden:
```swift
#if DEBUG
    .overlay(alignment: .bottom) {
        Text("Debug Mode")
            .font(.caption)
            .foregroundStyle(.red)
    }
#endif
```

### Option 3: Perfect Timing

Wait for animations to complete before taking screenshot:
- Let the view fully load
- Wait for any entrance animations
- Products should all be visible

---

## Screenshot Specifications

Apple's requirements for IAP screenshots:

**Accepted Formats:**
- PNG (preferred)
- JPEG

**Size:**
- Can be any iPhone screenshot size
- Simulator screenshots are automatically correct size

**Content Requirements:**
- Must show the IAP in context of your app
- Should clearly show where/how users access the purchase
- Can be the same screenshot for multiple IAPs (they just need context)

---

## Uploading to App Store Connect

### For Each Product (tip_small, tip_medium, tip_large):

1. **Navigate to product:**
   - App Store Connect → My Apps → CheckoutHero
   - In-App Purchases → Click on product

2. **Scroll to Review Information section**

3. **Upload screenshot:**
   - Click "Choose File" under Screenshot
   - Select your screenshot from Desktop
   - Click "Open"

4. **Save:**
   - Click "Save" in top right

5. **Repeat for all three products**
   - You can use the SAME screenshot for all three
   - It just needs to show the context where tips are available

---

## Alternative: Annotated Screenshot

If you want to make it extra clear, you can annotate your screenshot:

### Using Preview (macOS):
1. Open your screenshot in Preview
2. Click Markup toolbar button
3. Add an arrow or circle pointing to the IAP
4. Add text label: "Users can tip here"
5. Save

### Using Markup:
1. Right-click screenshot
2. Quick Actions → Markup
3. Add annotations
4. Save

**Note:** This is optional. A clean screenshot showing the Tip Jar view is sufficient.

---

## Screenshot Checklist

Before uploading to App Store Connect:

- ✅ Screenshot shows Tip Jar view
- ✅ All three tip options are visible
- ✅ Prices are correct ($0.99, $2.99, $4.99)
- ✅ UI looks clean and professional
- ✅ No debug overlays or test data
- ✅ File is PNG or JPEG format
- ✅ File size is reasonable (< 5MB)

---

## Common Issues

**Issue:** Products not showing in app
- **Fix:** Make sure StoreKit Configuration is set in scheme
- **Fix:** Check product IDs match exactly in StoreKit.storekit

**Issue:** Screenshot looks blurry
- **Fix:** Use Cmd+S in Simulator (not a photo of the screen)
- **Fix:** Make sure simulator is at 100% scale

**Issue:** Status bar shows "No Service"
- **Fix:** This is fine! Apple reviewers understand it's a simulator
- **Optional:** You can edit it out using Preview if you want

**Issue:** Can't find screenshot on Desktop
- **Fix:** Check Desktop folder
- **Fix:** Try taking screenshot again
- **Fix:** Check Simulator → File → New Screen Shot location in preferences

---

## After Taking Screenshot

### Next Steps:
1. ✅ Verify screenshot looks good
2. ✅ Upload to all three IAP products in App Store Connect
3. ✅ Fill in all other metadata (Display Name, Description, Price)
4. ✅ Verify each product shows "Ready to Submit"
5. ✅ Attach all three products to your app version

---

**Created:** March 13, 2026  
**For:** CheckoutHero IAP Setup
