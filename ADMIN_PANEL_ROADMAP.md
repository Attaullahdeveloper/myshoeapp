# 🛍️ Shoe App - Complete Admin Panel & Order Lifecycle Roadmap (UI + Backend)

Yeh document aapke Shoe App ke Admin Panel aur Backend (Supabase) ke next steps, order workflow, database schemas, aur features ki mukammal guide hai.

---

## 📑 Table of Contents
1. [Order Lifecycle & Workflow (Aagay Ka Procedure)](#1-order-lifecycle--workflow)
2. [Database (Supabase) Schema Requirements](#2-database-supabase-schema-requirements)
3. [Admin Panel Missing Features (UI + Backend)](#3-admin-panel-missing-features)
4. [Step-by-Step Action Plan](#4-step-by-step-action-plan)
5. [Ready-to-Run SQL Scripts](#5-ready-to-run-sql-scripts)

---

## 1. Order Lifecycle & Workflow

Abhi tak customer ka order create ho kar Supabase `orders` table mein ja raha hai (Status: `created`). Iske baad real-world e-commerce flow yeh hota hai:

```
[Customer Checkout] ➔ Status: 'created'
         │
         ▼
[Admin Review & Confirm] ➔ Status: 'processing'
  • Warehouse/Shop se shoe pack hota hai
  • Stock deduct hota hai
         │
         ▼
[Courier Booking & Dispatch] ➔ Status: 'shipped'
  • Courier select hota hai: (TCS, Leopards, Trax, DHL, Call Courier)
  • Tracking ID enter hoti hai (e.g. TRX-902341)
  • Customer ko app par live tracking number dikhta hai
         │
         ▼
[Customer Receives Parcel] ➔ Status: 'delivered'
  • Payment Status: 'paid' (Cash on Delivery receive ho jata hai)
         │
         ▼
[If Return / Cancel] ➔ Status: 'cancelled'
  • Stock wapas restore hota hai
```

---

## 2. Database (Supabase) Schema Requirements

Order tracking aur business management ke liye Supabase mein yeh columns aur tables zaroori hain:

### A. `orders` Table mein Zaroori Columns:
* `status`: `'created' | 'processing' | 'shipped' | 'delivered' | 'cancelled'`
* `payment_status`: `'pending' | 'paid' | 'failed'`
* `courier_name`: `'TCS' | 'Leopards' | 'Trax' | 'Call Courier' | 'M&P' | 'Self'`
* `tracking_id`: Courier consignment number (e.g. `TRX-98234123`)
* `shipped_at`: Timestamp jab parcel dispatch hua
* `delivered_at`: Timestamp jab customer ko mila

### B. `products` Table mein Inventory Columns:
* `stock_quantity`: Available stock (default: 50)
* `is_in_stock`: Boolean (`true` jab stock > 0, `false` jab 0 ho jaye)

### C. `coupons` Table (Promo / Discounts ke liye):
* `code`: Unique coupon text (e.g. `NIKE20`, `WELCOME10`)
* `discount_type`: `'percentage'` ya `'fixed'`
* `discount_value`: Amount ya % (e.g. 20 ya 500)
* `min_order_amount`: Minimum order value
* `expiry_date`: Expiry timestamp
* `is_active`: Boolean status

---

## 3. Admin Panel Missing Features

### Feature 1: Dashboard Analytics & Revenue Cards (UI)
Admin Dashboard par real-time business stats show hone chahiye:
* **Total Sales / Revenue**: Total kamai ($ ya PKR mein)
* **Pending Orders**: Kitne orders abhi process hone baqi hain (`created` + `processing`)
* **Delivered Orders**: Kamyabi se deliver hone wale orders
* **Today's Orders Counter**: Aaj ke din aane wale naye orders

### Feature 2: Courier & Tracking Number Dialog (Admin Orders)
* Jab Admin status `Shipped` select kare:
  - Ek clean popup dialog open ho
  - **Courier Dropdown**: (TCS, Leopards, Trax, DHL, etc.)
  - **Tracking ID Input**: Consignment number field
  - Save karne par customer ki **Order Details Screen** par tracking number aur courier badge live update ho jaye.

### Feature 3: Inventory / Stock Auto-Deduction (Backend)
* Jab customer order place kare, product ka `stock_quantity` automatic minus ho.
* Jab stock `0` ho jaye, app mein **"Out of Stock"** badge aaye aur customer buy na kar sake.
* Admin Panel par **Low Stock Alert** section jahan un shoes ki list ho jinka stock 5 se kam reh gaya ho.

### Feature 4: Promo Coupons Management (Admin UI + Checkout Integration)
* Admin nayi screen se promo codes banaye.
* Customer checkout par coupon apply kare toh discount live minus ho.

### Feature 5: Registered Customers / Users List
* Tamam registered buyers ka data:
  - Name, Email, Phone, aur Registration Date
  - Total Orders count aur total amount spent

### Feature 6: Print Invoice / Slip PDF
* Admin order card se 1-click invoice print kar sake jo parcel ke sath chipkayi jati hai.

### Feature 7: Role-Based Admin Protection
* Sirf specific Admin account hi Admin Dashboard khol sake (baqi aam customers ke liye access block ho).

---

## 4. Step-by-Step Action Plan

1. **Step 1: Courier & Tracking System (High Priority)**
   - Admin Orders View mein courier aur tracking ID enter karne ka dialog.
   - Customer Order Details screen par real-time courier aur tracking number display.

2. **Step 2: Admin Dashboard Analytics (High Priority)**
   - Dashboard par Revenue, Pending Orders, Today's Orders ke live stats cards.

3. **Step 3: Stock Auto-Decrement (Backend)**
   - Supabase SQL Trigger ya checkout function jo order bante hi stock minus kare.

4. **Step 4: Coupons Management (Marketing)**
   - Admin coupon creation screen + Checkout coupon application.

---

## 5. Ready-to-Run SQL Scripts (Supabase SQL Editor)

Aap Supabase Dashboard ➔ **SQL Editor** mein jakar yeh script run kar sakte hain:

```sql
-- 1. Orders table mein tracking columns add karein
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS courier_name TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS tracking_id TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS shipped_at TIMESTAMPTZ DEFAULT NULL,
ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMPTZ DEFAULT NULL;

-- 2. Products table mein stock aur availability_status columns add karein
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS availability_status TEXT DEFAULT 'in_stock',
ADD COLUMN IF NOT EXISTS stock_quantity INT DEFAULT 25,
ADD COLUMN IF NOT EXISTS is_in_stock BOOLEAN DEFAULT TRUE;

-- 3. Coupons table create karein
CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  discount_type TEXT NOT NULL DEFAULT 'percentage', -- 'percentage' or 'fixed'
  discount_value NUMERIC NOT NULL,
  min_order_amount NUMERIC DEFAULT 0,
  expiry_date TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```
