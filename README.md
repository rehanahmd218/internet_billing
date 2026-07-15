# EasyNet Billing - Internet Billing App

A comprehensive, offline-first Flutter application designed for Internet Service Providers (ISPs) and local network administrators to efficiently manage their users, track internet billing, and maintain records securely.

## 🎥 Video Demo

*(Upload your video demo here)*

## 🌟 Key Features

* **User Management:** Add, edit, and track users with detailed information including UID, Name, Mobile Number, Address, and Internet Speed (Mbps).
* **Billing System:** Generate, track, and manage monthly internet bills. Monitor pending and paid statuses effortlessly.
* **Interactive Dashboard:** Get a quick overview of your network's financial health, active users, and pending collections.
* **Offline-First Architecture:** Built on top of robust local SQLite databases (`sqflite`), ensuring the app works perfectly without an active internet connection.
* **Cloud Backup & Restore:** Seamlessly backup your local database to Google Drive and restore it on any device using secure Google OAuth authentication.
* **Dark & Light Mode:** fully responsive UI with support for both Dark and Light themes tailored via `GetX` and Material 3.

## 🛠 Technologies & Architecture

* **Framework:** Flutter & Dart
* **State Management & Routing:** [GetX](https://pub.dev/packages/get)
* **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
* **Cloud Integration:** Google Drive API via `googleapis` & `google_sign_in`
* **Architecture Pattern:** MVC-inspired using GetX Controllers

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (>=3.10.4 <4.0.0)
* Dart SDK
* Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/internet_billing_2.git
   cd internet_billing_2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Google Drive API Setup**
   To enable the Cloud Backup feature, you must configure the Google Drive API. Please follow the detailed instructions in the [GOOGLE_DRIVE_SETUP.md](GOOGLE_DRIVE_SETUP.md) file.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── common/       # Reusable widgets, constants, and theme colors
├── controllers/  # GetX controllers for state management and business logic
├── database/     # SQLite database helpers and migrations
├── models/       # Data models (UserModel, BillModel)
├── routes/       # Application routing and GetPages configurations
├── screens/      # UI Views (Dashboard, Users List, Settings, etc.)
├── services/     # External services (Google Drive Backup service)
├── utils/        # Helper functions and extensions
└── main.dart     # Application entry point
```

## 🛡️ Privacy & Security
EasyNet Billing stores all billing and user data locally on your device. The optional cloud backup feature stores encrypted SQLite databases within a dedicated folder in your personal Google Drive, ensuring that only you have access to your sensitive customer data.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
