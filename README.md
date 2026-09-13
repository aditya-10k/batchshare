<div align="center">

  <img src="assets/logo.png" alt="Batchshare Logo" width="120" />

  # Batchshare Frontend 📱💻

  **Cross-Platform Flutter Web & Native Android Application for Batchshare**

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![BLoC](https://img.shields.io/badge/State_Management-BLoC_9.1-8A2BE2?style=for-the-badge)](https://bloclibrary.dev/)
  [![Android](https://img.shields.io/badge/Platform-Android_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://drive.google.com/uc?export=download&id=1swGE-w1Li7W7tZHhaf4mPjPPMIHlMN_H)
  [![Web](https://img.shields.io/badge/Platform-Web_SPA-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)](https://adityx10-batchshare.hf.space)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

  <br />

  <p align="center">
    <a href="https://adityx10-batchshare.hf.space"><b>🌐 Open Live Web App</b></a> •
    <a href="https://drive.google.com/uc?export=download&id=1swGE-w1Li7W7tZHhaf4mPjPPMIHlMN_H"><b>📱 Download Android APK</b></a> •
    <a href="#-key-features"><b>✨ Features</b></a> •
    <a href="#️-architecture--state-management"><b>🏗️ Architecture</b></a> •
    <a href="#️-getting-started"><b>⚙️ Getting Started</b></a>
  </p>

</div>

---

## 📖 Overview

The **Batchshare Frontend** is a modern, responsive cross-platform client built with **Flutter 3.x** and **Dart**. It provides a sleek, dark-mode glassmorphic user experience across web browsers and native Android mobile devices, enabling frictionless text and file exchange via temporary rooms, custom URL shortening, and email broadcasting.

---

## ✨ Key Features

- **⚡ Real-Time Live Messaging**: Uses `stomp_dart_client` to subscribe to room STOMP channels over WebSockets with automatic reconnection and instant UI sync.
- **🎨 Glassmorphic Dark UI**: Custom modern aesthetics featuring neon accents, subtle gradient containers, and fluid animations.
- **📱 Responsive Multi-Device Layout**: Dynamic UI switching via `ResponsiveWidget` providing tailored layouts for mobile viewports (`<= 700px`) and wide desktop displays.
- **📁 File Picker & Cloudinary CDN**: Direct device file picking (`file_picker`) with progress tracking and direct CDN previews.
- **🔗 Smart URL Shortener Dialog**: Built-in modal allowing users to create custom vanity URLs, pick TTL duration, and copy links with one tap.
- **📧 Email Dispatcher Modal**: Select messages and file links to send directly to recipient emails in one click.
- **🔄 Universal Web Redirect Helper**: Intercepts path/hash routing in web browsers to resolve vanity short URLs instantly before mounting the app.

---

## 🏗️ Architecture & State Management

The application is structured following the **BLoC (Business Logic Component)** architectural pattern:

```
lib/
├── Config/
│   ├── ResponsiveWidget.dart        # Screen breakpoint management
│   ├── redirect_helper.dart         # Conditional routing resolver
│   ├── redirect_helper_web.dart     # Browser location & short code redirect
│   └── redirect_helper_stub.dart    # Mobile stub
├── Elements/
│   ├── AppScaffold.dart             # Global navigation & header
│   ├── Loading.dart                 # Custom loaders & spinners
│   └── MessageBubble.dart           # Render text snippets, files & copy buttons
├── HomePage/
│   ├── Bloc/
│   │   ├── HomePageBloc.dart        # Core business logic, WebSocket & HTTP
│   │   ├── HomePageEvent.dart       # Bloc user actions & socket triggers
│   │   └── HomePageState.dart       # Reactive UI states
│   └── Views/
│       ├── HomePage.dart            # Main container
│       └── Pages/
│           ├── LandingPage.dart     # PIN entry & room creation
│           ├── ChatPage.dart        # Real-time room stream & file sharing
│           ├── MailPage.dart        # Email broadcast dialog
│           └── UrlShortenerDialog.dart # Custom short link generator
└── main.dart                        # App bootstrap & routing configuration
```

---

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.9.2` or later)
- Android Studio / Android SDK (for Android builds)
- Google Chrome (for Web development)

### Installation & Run

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run in Chrome (Development)**:
   ```bash
   flutter run -d chrome
   ```

3. **Build Web Release**:
   ```bash
   flutter build web --release
   ```

4. **Build Android APK**:
   ```bash
   flutter build apk --release
   ```
   The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
