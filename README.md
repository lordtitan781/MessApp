# 🍽️ MessApp Frontend

A Flutter-based frontend for the Mess Management App.  
This repository contains the mobile frontend UI & state management.  
➡️ Backend and Firebase setup need to be configured after cloning.

---

## 📌 Features

- Role-based navigation (Student, Admin)
- Digital Mess Card view
- Student photo upload page
- Mess menu & dinner provider with state management
- Organized Flutter architecture (core, models, pages, providers)

---

## 🚀 Tech Stack

- Flutter (Dart)
- Provider (State management)
- SharedPreferences (Local storage)
- Firebase: Authentication, Firestore, Storage

---

## ✅ Prerequisites

Before running the app, install:

- Flutter SDK (latest stable)
- Android Studio or VS Code
- Xcode (macOS only, for iOS builds)
- Emulator or physical device

Check Flutter setup:

```bash
flutter doctor
```

---

## 📦 Installation

### 1. Clone this repository

```bash
git clone <repo_url>
cd MessApp
```

### 2. Install dependencies

```bash
flutter pub get
```

---

## 🔧 Firebase Setup

### 1. Create a Firebase Project:

- Go to [Firebase Console](https://console.firebase.google.com/) → Add Project → Follow steps.

### 2. Add Your Apps:

**Android:**
- Add your app using the package name (e.g., `com.example.messapp`)
- Download `google-services.json` → Place it in `android/app/`

**iOS:**
- Add your app using the Bundle ID
- Download `GoogleService-Info.plist` → Place it in `ios/Runner/`
- Open Xcode → Add `GoogleService-Info.plist` to the Runner target

### 3. Enable Firebase Services:

- **Authentication:** Enable Email/Password (or Google Sign-In if required)
- **Firestore:** Create collections like `users` and `mess`
- **Storage:** Create a storage bucket for profile pictures

🔹 Firebase initialization is already implemented in the code, so no further code changes are needed. You just need to add the config files.

---

## ▶️ Running the App

### Android

```bash
flutter run
```

### iOS (macOS only)

```bash
flutter run -d ios
```

### Web

```bash
flutter run -d chrome
```

---

## 📂 Project Structure

```
lib/
 ├── core/          → App-level utilities, themes, constants
 ├── models/        → Data models (user, mess, menu, etc.)
 ├── pages/         → Screens and UI pages
 ├── providers/     → State management logic
 └── main.dart      → Entry point of the app
```

---

## 🧹 Useful Commands

- Clean build cache → `flutter clean`
- Analyze code → `flutter analyze`
- Run tests (if available) → `flutter test`

---

## 🔐 Notes

- SharedPreferences stores Auth Tokens and Email information locally.
- Provider handles UI state like menu selection, mess card balance, and photo upload.
- Firebase is already integrated; just ensure you add the correct configuration files for your project.
