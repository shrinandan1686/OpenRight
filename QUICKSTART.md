# OpenRight - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Start the Backend Server

Open a new terminal and run:

```bash
cd backend
npm install
./setup.sh         # Creates KV namespaces and configures wrangler.toml
npm run dev        # Starts server at http://localhost:8787
```

Leave this terminal running.

---

### 2. Start the Mobile App

Open another terminal and run:

```bash
flutter pub get
flutter run        # Runs on connected device or emulator
```

### 3. Test the App

1. **On your device/emulator**, you'll see the OpenRight home screen.
2. **Paste a YouTube URL**: `https://youtube.com/watch?v=dQw4w9WgXcQ`
3. **Tap "Create Smart Link"**.
4. **Copy the generated link** and test it on a mobile device!

---

## 🐛 Troubleshooting

### "Cannot connect to backend"
- Ensure backend server is running: `cd backend && npm run dev`
- Check `lib/services/api_service.dart` - if using a physical device, use your local IP instead of `localhost`.
- Find your IP: Run `ifconfig | grep "inet " | grep -v 127.0.0.1` on Mac.

### "KV namespace error"
Run `cd backend && ./setup.sh` to create KV namespaces automatically.

---

## 🎯 Next Steps

1. **Deploy backend**: `cd backend && npx wrangler deploy`
2. **Update app**: Point to production URL in `lib/services/api_service.dart`.
3. **Build apps**: `flutter build apk --release` (Android) or `flutter build ios --release` (iOS).

---

## 📖 Full Documentation

See [README.md](file:///Users/shubhashreebhat/Documents/OpenRight/README.md) for comprehensive docs.
