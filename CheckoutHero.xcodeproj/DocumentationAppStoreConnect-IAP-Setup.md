# App Store Connect - In-App Purchase Setup Guide

## 📝 Complete Setup Instructions for CheckoutHero Tips

---

## TASK 1: Complete All 3 IAP Products

### Product 1: Small Tip 🙏

**Basic Information:**
- **Reference Name:** `Small Tip`
- **Product ID:** `tip_small`
- **Type:** Consumable
- **Cleared for Sale:** ✅ Yes

**Pricing:**
- **Price Tier:** Tier 1 ($0.99 USD)

**Localization (English - U.S.):**
- **Display Name:** `Small Tip 🙏`
- **Description:**
```
Support CheckoutHero with a small tip! Your generosity helps keep this app free and improving. Every contribution makes a difference!
```

**Review Information:**
- **Screenshot:** Upload screenshot of Tip Jar view (see instructions below)
- **Review Notes:** `This is a voluntary tip to support the app. No additional features are unlocked.`

---

### Product 2: Medium Tip 💙

**Basic Information:**
- **Reference Name:** `Medium Tip`
- **Product ID:** `tip_medium`
- **Type:** Consumable
- **Cleared for Sale:** ✅ Yes

**Pricing:**
- **Price Tier:** Tier 3 ($2.99 USD)

**Localization (English - U.S.):**
- **Display Name:** `Medium Tip 💙`
- **Description:**
```
Show your appreciation with a medium tip! Help fund new features and ongoing development. Your support means everything!
```

**Review Information:**
- **Screenshot:** Upload screenshot of Tip Jar view (see instructions below)
- **Review Notes:** `This is a voluntary tip to support the app. No additional features are unlocked.`

---

### Product 3: Large Tip 🌟

**Basic Information:**
- **Reference Name:** `Large Tip`
- **Product ID:** `tip_large`
- **Type:** Consumable
- **Cleared for Sale:** ✅ Yes

**Pricing:**
- **Price Tier:** Tier 5 ($4.99 USD)

**Localization (English - U.S.):**
- **Display Name:** `Large Tip 🌟`
- **Description:**
```
Make a big impact with a large tip! You're making a real difference in keeping CheckoutHero awesome. Thank you for being amazing!
```

**Review Information:**
- **Screenshot:** Upload screenshot of Tip Jar view (see instructions below)
- **Review Notes:** `This is a voluntary tip to support the app. No additional features are unlocked.`

---

## TASK 2: Attach IAPs to App Submission

### Step-by-Step Instructions:

1. **Navigate to your app version:**
   - Go to **App Store Connect** → **My Apps** → **CheckoutHero**
   - Click on your version (e.g., **1.0**) in the left sidebar

2. **Find the In-App Purchases section:**
   - Scroll down to **"In-App Purchases and Subscriptions"** section
   - You should see a **"+" button** or **"Add In-App Purchase"** button

3. **Add all three products:**
   - Click the **"+"** button
   - A modal will appear showing available products
   - Select all three:
     - ☑️ **tip_small** - Small Tip
     - ☑️ **tip_medium** - Medium Tip
     - ☑️ **tip_large** - Large Tip
   - Click **"Done"**

4. **Verify they're attached:**
   - All three products should now appear in the list
   - Each should show **"Ready to Submit"** status
   - They will be reviewed together with your app binary

---

## 📸 Taking IAP Screenshots

### Instructions:

1. **Run the app in simulator:**
   - Make sure StoreKit Configuration is set up (StoreKit.storekit)
   - Run on **iPhone 15 Pro** or **iPhone 15 Pro Max** for best results

2. **Navigate to Tip Jar:**
   - Open Settings → Support CheckoutHero (or wherever you have the Tip Jar)

3. **Take the screenshot:**
   - Press **Cmd+S** in the Simulator
   - Screenshot will be saved to Desktop

4. **Upload to App Store Connect:**
   - Go to each product's **Review Information** section
   - Click **"Choose File"** under Screenshot
   - Upload the same screenshot for all three products (showing context)

### Screenshot Requirements:
- Must show the IAP in context of your app
- Should be clear and unobscured
- Can be same screenshot for all three products
- Format: PNG or JPEG
- The screenshot shows where users can find and purchase the tip

---

## ✅ Verification Checklist

Before submitting, verify each product has:

- ✅ Reference Name filled in
- ✅ Product ID matches code (`tip_small`, `tip_medium`, `tip_large`)
- ✅ Type set to **Consumable**
- ✅ Price configured (Tier 1, 3, or 5)
- ✅ At least one localization (Display Name + Description)
- ✅ Screenshot uploaded
- ✅ "Cleared for Sale" is checked
- ✅ Status shows **"Ready to Submit"** (not "Missing Metadata")
- ✅ Product is attached to your app version

---

## 🚨 Common Issues & Solutions

**Issue:** Product shows "Missing Metadata"
- **Solution:** Make sure you've filled in ALL required fields, especially:
  - At least one localization with Display Name and Description
  - Screenshot uploaded
  - Price tier selected

**Issue:** Can't find the product to attach to app version
- **Solution:** Make sure the product status is "Ready to Submit" first

**Issue:** Products not loading in simulator
- **Solution:** Verify StoreKit Configuration is set in scheme and product IDs match exactly

---

## 💡 Review Notes for Apple

If asked for additional information during review, you can provide:

**Purpose of IAPs:**
```
These are voluntary tips that allow users to support the development of CheckoutHero. 
They are clearly labeled as tips and do not unlock any additional features, content, 
or functionality. Users can fully use the app without making any purchases.
```

**Why Consumable Type:**
```
Tips are consumable products because users may want to tip multiple times to show 
ongoing support. Unlike non-consumables, this allows users to purchase the same 
tip tier multiple times if they wish.
```

---

## 📅 Timeline

Once everything is completed:
- IAPs are reviewed together with your app submission
- Typical review time: 24-48 hours (sometimes faster)
- You'll receive one decision for both the app and the IAPs

---

**Created:** March 13, 2026
**App:** CheckoutHero
**Version:** 1.0
