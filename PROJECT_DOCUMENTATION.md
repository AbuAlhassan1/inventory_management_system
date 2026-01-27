# Project Document: Local Inventory & POS System (LIPS)

## 1. Project Vision

A high-performance, local-first desktop application (Windows/macOS) optimized for the Iraqi retail and wholesale market. The system features a **primary Arabic RTL interface**, dual-currency support (IQD/USD), and a minimalist `shadcn_ui` aesthetic.

## 2. Technical Stack

* **Framework:** Flutter (Desktop)
* **UI System:** `shadcn_ui` (RTL-adapted)
* **Localization:** `flutter_localizations` (Primary: Arabic `ar-IQ`, Secondary: English `en-US`)
* **Database:** SQLite via `Drift` ORM
* **State Management:** Riverpod (Recommended for Cursor AI efficiency)
* **Fonts:** Cairo or Tajawal (Professional Arabic Typography)

---

## 3. Database Schema (Iraqi Market Requirements)

### 3.1. Core Tables

* **Products:** - `id`, `sku`, `name_ar`, `name_en`
  - `barcode` (Indexed for scanners)
  - `cost_price_usd`: Double (Wholesale often in USD)
  - `sell_price_iqd`: Int (Retail usually in IQD)
  - `sell_price_usd`: Double
  - `quantity`: Int
  - `category_id`: FK
* **CurrencyConfig:** - `id`
  - `usd_to_iqd_rate`: Int (e.g., 1500 for $1)
  - `last_updated`: DateTime
* **Categories:** `id`, `name_ar`, `name_en`

### 3.2. POS & Sales

* **Sales:** - `id`
  - `total_iqd`, `total_usd`
  - `received_amount_iqd`
  - `change_given_iqd`
  - `payment_method`: String (Cash, Card, **Debt/Wasl**)
  - `created_at`: DateTime
* **SaleItems:** `id`, `sale_id`, `product_id`, `quantity`, `price_at_sale_iqd`

---

## 4. Functional Modules

### 4.1. Dual-Currency Engine (Market Rate Logic)

* **Daily Exchange Rate:** A global setting to update the IQD/USD rate.
* **Auto-Calculation:** Entering a price in USD should automatically suggest the IQD price based on the market rate.
* **Currency Toggle:** Ability to switch the POS display between IQD and USD instantly.

### 4.2. Arabic RTL UI/UX

* **RTL Layout:** Navigation sidebar on the **Right**, content on the Left.
* **Arabic Typography:** Full support for Arabic characters with proper line heights for the **Cairo** font.
* **Local Formatting:** - IQD: No decimal places (e.g., 25,250 د.ع)
  - USD: Two decimal places (e.g., $15.50)

### 4.3. POS & Printing

* **The "Wasl" System:** Generate thermal receipts (80mm) in Arabic.
* **Barcode Workflow:** The "Sale" screen must have a persistent focus on the barcode input field for rapid scanning.
* **Debt Management:** Track "Al-Dayn" (Customer Debt) by linking unpaid sales to a customer name/profile.

---

## 5. UI/UX Standards

* **Theme:** Support for `ShadTheme` Dark and Light modes.
* **Components:** Use `ShadTable` for high-density inventory views.
* **Feedback:** Use `ShadToast` for success/error messages in Arabic.
* **Navigation:** Sidebar icons for:
  - (لوحة التحكم) Dashboard
  - (المخزن) Inventory
  - (نقطة البيع) POS
  - (الديون) Debts
  - (الإعدادات) Settings
