# OpenRight - Smart Link Shortener

> Transform YouTube links into smart short links that bypass in-app browsers and open directly in native apps.

## 🎯 What is OpenRight?

OpenRight is a minimalist mobile app that creates intelligent shortened links. When shared on social platforms like Instagram or Facebook, these links automatically open in the YouTube app instead of frustrating in-app browsers.

**Perfect for**: Content creators, marketers, and anyone who shares YouTube content frequently.

## 🚀 Quick Start

### 📋 Prerequisites

- **Flutter SDK 3.5.0+** ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Node.js 20+**
- **Cloudflare Account** (for backend hosting)
- **Android/iOS device or emulator**

### 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shrinandan1686/OpenRight.git
   cd OpenRight
   ```

2. **Setup Frontend (Flutter)**
   ```bash
   flutter pub get
   ```

3. **Setup Backend (Cloudflare Workers)**
   ```bash
   cd backend
   npm install
   ./setup.sh  # Automatically creates KV namespaces and updates wrangler.toml
   ```

### 💻 Running Locally

**Terminal 1: Backend Server**
```bash
cd backend
npm run dev
```
Starts backend at `http://localhost:8787`.

**Terminal 2: Mobile App**
```bash
# Run on connected device or emulator
flutter run
```

> [!NOTE]
> For physical devices, update `API_BASE_URL` in `lib/services/api_service.dart` to your computer's local IP (e.g., `http://192.168.1.XXX:8787`).

## 📂 Project Structure

```
OpenRight/
├── lib/                      # Flutter app source
│   ├── main.dart             # App entry point
│   ├── screens/              # App screens (Home, Result)
│   ├── services/             # API communication
│   └── utils/                # URL validation helpers
├── backend/                  # Cloudflare Workers backend
│   ├── worker.js             # Serverless logic
│   ├── wrangler.toml         # Cloudflare config
│   └── setup.sh              # KV setup script
├── android/                  # Android platform files
├── ios/                      # iOS platform files
└── pubspec.yaml              # Flutter dependencies
```

## 🎨 Technology Stack

- **Frontend**: Flutter + Dart
- **Backend**: Cloudflare Workers + Node.js
- **Storage**: Cloudflare Workers KV (Edge storage)
- **Deep Linking**: `url_launcher` custom schemes (`vnd.youtube://`)

## 🧪 Testing

1. Start both backend and mobile app.
2. In the app, paste a YouTube link: `https://youtube.com/watch?v=dQw4w9WgXcQ`
3. Tap **"Create Smart Link"**.
4. Test the generated link by sharing it or opening it on a mobile device.

## 🚀 Deployment

### 1. Deploy Backend
```bash
cd backend
npx wrangler deploy
```
Update `lib/services/api_service.dart` with your production URL.

### 2. Build Mobile App
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release
```

## 📄 License
MIT License - feel free to use this however you'd like!

---

**Built with ❤️ for creators who deserve better link sharing.**
