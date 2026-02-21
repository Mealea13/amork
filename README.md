# Amork — Cambodian Food Ordering App

A modern mobile application for discovering and ordering authentic Cambodian cuisine, built with Flutter, powered by .NET, and backed by PostgreSQL.

---



## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile UI | Flutter (Dart) | Cross-platform app interface |
| Backend | ASP.NET Core (.NET) | REST API and business logic |
| Database | PostgreSQL | Data storage and persistence |
| DB Client | DBeaver | Schema management and queries |
| API Testing | Postman | API testing and collection management |
| Network | Local Wi-Fi (LAN) | Device-to-backend communication |

---

## Project Structure

```
Amork/
│
├── flutter_app/                       # Flutter Frontend
│   └── lib/
│       └── config/
│           └── app_config.dart        # [!] Wi-Fi IP configured here
│
├── backend/                           # .NET Backend
│   ├── AmorkApp.http                  # [!] Wi-Fi IP configured here
│   ├── Properties/
│   │   └── launchSettings.json        # [!] Wi-Fi IP configured here
│   └── appsettings.json               # [!] Database credentials configured here
│
└── postman/
    └── amork_collection.json          # [!] Wi-Fi IP configured here (base_url)
```

> **Note:** Every time your Wi-Fi IP address changes, you must update all 4 files listed above.

---

## Prerequisites

Make sure the following tools are installed before starting:

| Tool | Purpose | Download |
|------|---------|----------|
| Flutter SDK | Run the mobile app | https://flutter.dev |
| .NET SDK (8+) | Run the backend API | https://dot.net |
| PostgreSQL | Database server | https://www.postgresql.org |
| DBeaver | Database GUI client | https://dbeaver.io |
| Postman | API testing | https://postman.com |

---

## Setup Guide

### Step 1 — Find Your Local Wi-Fi IP

Your phone and PC must be connected to the **same Wi-Fi network**.

**Windows:**
```powershell
ipconfig
# Look for: IPv4 Address → e.g. 192.168.100.7
```

**macOS:**
```bash
ifconfig | grep "inet "
# Look for: inet 192.168.x.x
```

**Linux:**
```bash
ip addr show | grep "inet "
# Look for: inet 192.168.x.x
```

The example IP used throughout this project is `192.168.100.7`. Replace it with your own IP wherever it appears.

---

### Step 2 — Configure IP Address in All Files

You must update the IP address in the following 4 files:

---

#### 1. `app_config.dart` — Flutter App

```dart
// lib/config/app_config.dart

class AppConfig {
  static const String baseUrl = 'http://192.168.100.7:5000'; // Replace with your IP
}
```

---

#### 2. `AmorkApp.http` — .NET HTTP Client

```
# AmorkApp.http

@baseUrl = http://192.168.100.7:5000   # Replace with your IP
```

---

#### 3. `launchSettings.json` — .NET Launch Settings

```json
{
  "profiles": {
    "AmorkApp": {
      "applicationUrl": "http://192.168.100.7:5000"
    }
  }
}
```

---

#### 4. `amork_collection.json` — Postman Collection

Open the file, scroll to the bottom `variable` array, and update the `base_url` value:

```json
{
  "variable": [
    {
      "key": "base_url",
      "value": "http://192.168.100.7:5000"
    }
  ]
}
```

---

### Step 3 — Configure the Database

Open `appsettings.json` in your .NET backend root folder and update it to match your local PostgreSQL setup:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=amork_db;Username=postgres;Password=YOUR_PASSWORD_HERE"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "AmorkSecretKey2024SuperLongSecretKeyForJWT!",
    "Issuer": "AmorkApp",
    "Audience": "AmorkUsers"
  }
}
```

| Field | What to Change |
|-------|---------------|
| `Host` | Keep as `localhost` (same machine) |
| `Port` | Keep as `5432` (default PostgreSQL port) |
| `Database` | Keep as `amork_db` |
| `Username` | Your PostgreSQL username (usually `postgres`) |
| `Password` | **Replace with your own PostgreSQL password** |
| `Jwt.Key` | Keep as-is or replace with your own secret key |

---

### Step 4 — Run Database Schema in DBeaver

Follow these steps to build the full database from scratch:

1. Open **DBeaver** and connect to your local PostgreSQL server.

2. Create the database by right-clicking your connection and selecting **Create New Database**, or run:
   ```sql
   CREATE DATABASE amork_db;
   ```

3. Double-click `amork_db` to set it as the active database.

4. Open a new SQL Editor via `Ctrl + ]` or Menu → SQL Editor → New SQL Script.

5. Copy the entire contents of the schema SQL file from the project and paste it into the editor.

6. Click **Execute SQL Script** or press `Alt + X` to run all statements.

   The script will automatically:
   - Create all tables (users, foods, orders, cart, payments, reviews, etc.)
   - Set up performance indexes for all major queries
   - Install auto-update triggers on `updated_at` columns
   - Install a rating trigger that recalculates food ratings on new reviews
   - Seed 4 default categories (Food, Drink, Dessert, Snack)
   - Seed 80+ food items across all categories
   - Insert default app settings (delivery fee, tax rate, minimum order, etc.)

7. Verify the setup ran correctly:
   ```sql
   -- Should return 83
   SELECT COUNT(*) AS total_foods FROM foods;

   -- Should show 4 categories with item counts
   SELECT category_id, COUNT(*) AS items
   FROM foods
   GROUP BY category_id
   ORDER BY category_id;
   ```

---

### Step 5 — Import Postman Collection

1. Open **Postman**.

2. Click the **Import** button in the top-left corner.

3. Select the **Raw Text** tab in the import dialog.

4. Open `amork_collection.json`, select all content (`Ctrl + A`), and copy it (`Ctrl + C`).

5. Paste the contents into the Raw Text field in Postman.

6. Click **Continue** then **Import**.

7. The Amork App collection will appear in your sidebar, organized into the following groups:

   ```
   Amork App
    Authentication
    Categories
    Foods
    Cart
    Orders
    Payment
    User Profile
    Notifications
    Favorites
    Reviews
    App Settings
   ```

> **Auto Token Saving:** After a successful Register (201) or Login (200), Postman's built-in test script automatically saves `auth_token` and `user_id` to environment variables. All subsequent requests use them without manual setup.

---

### Step 6 — Restore .NET Backend Packages

After extracting the project ZIP file, NuGet packages will be missing. Run the following commands in order:

```bash
# Navigate to your backend project folder
cd path/to/AmorkApp/backend

# Restore all missing NuGet packages
dotnet restore

# Build the project to confirm everything compiles
dotnet build

# Start the API server
dotnet run
```

Expected output when running successfully:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://192.168.100.7:5000
      Application started. Press Ctrl+C to shut down.
```

> If you see package errors, verify your .NET SDK version with `dotnet --version`. This project requires **.NET 8 or higher**.

---

### Step 7 — Restore Flutter Packages

After extracting the Flutter project ZIP file, dependencies may be missing or outdated. Run the following commands:

```bash
# Navigate to your Flutter project folder
cd path/to/AmorkApp/flutter_app

# Download all packages defined in pubspec.yaml
flutter pub get

# (Optional) Clean the build cache if you encounter errors
flutter clean
flutter pub get

# Run the app on your connected device or emulator
flutter run
```

> **Android Device:** Enable Developer Options and USB Debugging on your phone, connect via USB cable, then run `flutter devices` to confirm it is detected.

> **iOS Device:** Requires macOS with Xcode installed. Open `ios/Runner.xcworkspace` in Xcode for signing and provisioning setup before running.

---

## API Reference

All endpoints require the `Authorization: Bearer {{auth_token}}` header unless stated otherwise.

| Group | Method | Endpoint | Description |
|-------|--------|----------|-------------|
| **Authentication** | `POST` | `/api/auth/register` | Create a new account |
| | `POST` | `/api/auth/login` | Login and receive token |
| | `POST` | `/api/auth/google` | Google OAuth login |
| | `POST` | `/api/auth/logout` | Invalidate current session |
| **Categories** | `GET` | `/api/categories` | List all active categories |
| | `POST` | `/api/categories` | Create a new category |
| | `PUT` | `/api/categories/:id` | Update a category |
| | `DELETE` | `/api/categories/:id` | Delete a category |
| **Foods** | `GET` | `/api/foods` | List all foods (paginated, filterable) |
| | `GET` | `/api/foods/popular` | Get top popular items |
| | `GET` | `/api/foods/search?q=` | Search food by name |
| | `POST` | `/api/foods` | Create a food item |
| | `PUT` | `/api/foods/:id` | Update a food item |
| | `DELETE` | `/api/foods/:id` | Delete a food item |
| **Cart** | `GET` | `/api/cart` | View current user cart |
| | `POST` | `/api/cart/add` | Add item to cart |
| | `PUT` | `/api/cart/:id` | Update item quantity |
| | `DELETE` | `/api/cart/:id` | Remove item from cart |
| | `DELETE` | `/api/cart/clear` | Clear the entire cart |
| **Orders** | `POST` | `/api/orders` | Place a new order |
| | `GET` | `/api/orders` | View order history |
| | `GET` | `/api/orders/:id` | Get order details |
| | `PATCH` | `/api/orders/:id/status` | Update order status |
| | `POST` | `/api/orders/:id/cancel` | Cancel an order |
| **Payment** | `POST` | `/api/payment/cash` | Process cash on delivery |
| | `POST` | `/api/payment/qr-code/generate` | Generate QR payment code |
| | `GET` | `/api/payment/:id/status` | Check payment status |
| | `GET` | `/api/payment/history` | View payment history |
| **Profile** | `GET` | `/api/profile` | Get user profile |
| | `PUT` | `/api/profile` | Update profile info |
| | `PUT` | `/api/profile/change-password` | Change password |
| | `DELETE` | `/api/profile/delete` | Delete account |
| | `GET` | `/api/profile/addresses` | List saved addresses |
| | `POST` | `/api/profile/addresses` | Add a new address |
| | `DELETE` | `/api/profile/addresses/:id` | Remove an address |
| **Favorites** | `GET` | `/api/favorites` | List favorited foods |
| | `POST` | `/api/favorites` | Add food to favorites |
| | `DELETE` | `/api/favorites/:food_id` | Remove from favorites |
| **Reviews** | `GET` | `/api/reviews/food/:id` | Get reviews for a food item |
| | `POST` | `/api/reviews` | Submit a review |
| | `DELETE` | `/api/reviews/:id` | Delete a review |
| **Notifications** | `GET` | `/api/notifications` | Get all notifications |
| | `PATCH` | `/api/notifications/:id/read` | Mark one as read |
| | `PATCH` | `/api/notifications/mark-all-read` | Mark all as read |
| | `DELETE` | `/api/notifications/:id` | Delete a notification |
| **App** | `GET` | `/api/config` | Get app configuration |
| | `GET` | `/api/restaurant-info` | Get restaurant details |
| | `POST` | `/api/support/contact` | Send a support message |

---

## Database Schema

| Table | Description |
|-------|-------------|
| `users` | Accounts, OAuth info, and member type |
| `user_addresses` | Saved delivery addresses per user |
| `user_sessions` | JWT tokens and device session info |
| `categories` | Food, Drink, Dessert, Snack categories |
| `foods` | Menu items with pricing and details |
| `cart_items` | Active shopping cart per user |
| `orders` | Order records with delivery info |
| `order_items` | Individual line items within each order |
| `payments` | Cash and QR payment records |
| `promotions` | Time-limited discount banners |
| `coupons` | Discount coupon codes |
| `reviews` | Star ratings and written reviews |
| `favorites` | Saved favorite foods per user |
| `notifications` | In-app push notifications |
| `notification_settings` | Per-user notification preferences |
| `support_tickets` | Customer support messages |
| `app_settings` | Delivery fee, tax rate, minimum order, etc. |
| `restaurant_info` | Restaurant name, address, and hours |

**Key database features:**
- Auto-update triggers keep `updated_at` always current on every record change
- Rating trigger automatically recalculates food average ratings on every new review
- Performance indexes on users, foods, orders, and notifications for fast queries
- UUID primary keys for users, orders, cart items, and payments
- Check constraints enforce valid status values and non-negative prices throughout

---

## Quick Test Checklist

Use this checklist to verify your entire setup is working end-to-end before development:

**Database**
- [ ] PostgreSQL service is running on port `5432`
- [ ] `amork_db` database has been created
- [ ] Full schema SQL executed without errors in DBeaver
- [ ] `SELECT COUNT(*) FROM foods;` returns `83`
- [ ] `SELECT * FROM categories;` returns 4 rows

**Backend API**
- [ ] `appsettings.json` updated with correct database password
- [ ] `dotnet restore` completed without errors
- [ ] `dotnet build` compiled successfully
- [ ] `dotnet run` shows API listening on your IP and port

**Flutter App**
- [ ] `app_config.dart` updated with correct Wi-Fi IP
- [ ] `flutter pub get` downloaded all packages without errors
- [ ] App launches on device or emulator without crashes
- [ ] Home screen displays food categories and menu items correctly

**Postman**
- [ ] `amork_collection.json` imported successfully
- [ ] `base_url` variable set to your Wi-Fi IP
- [ ] `POST /api/auth/register` returns `201 Created` with a token
- [ ] `auth_token` is auto-saved in Postman environment variables
- [ ] `GET /api/foods` returns the full food list

---

## Common Issues and Fixes

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `Connection refused` in Flutter | Wrong IP or backend not running | Verify IP in `app_config.dart` and run `dotnet run` |
| `password authentication failed` | Wrong database password | Update `Password=` in `appsettings.json` |
| Missing packages after ZIP extract | NuGet or pub cache not included in ZIP | Run `dotnet restore` and `flutter pub get` |
| Postman returns `401 Unauthorized` | Token missing or expired | Re-run the Login request to get a fresh token |
| Phone cannot reach the API | Device on a different network | Connect both phone and PC to the same Wi-Fi |
| `SocketException` in Flutter | Wrong `baseUrl` in config | Update IP in `app_config.dart` and hot restart |
| `dotnet: SDK not found` | .NET SDK not installed | Install .NET 8 or higher from https://dot.net |
| DBeaver script fails midway | Duplicate data or missing extension | Drop and recreate `amork_db`, then re-run the script |

---

## Developer

**Him Somealea** — Amork App v3.0.0

*Bringing authentic Cambodian flavors to your fingertips.*
