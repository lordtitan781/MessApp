# 🍽️ MessApp Frontend  

A Flutter-based frontend for the Mess Management App.  
This repository only contains the mobile frontend UI & state management.  
➡️ Backend and Firebase setup are not included here.  

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

1. Clone this repository  

```bash
git clone <repo_url>  
cd MessApp  
```

2. Install dependencies  

```bash
flutter pub get  
```

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

