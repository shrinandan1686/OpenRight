# OpenRight - Smart Link Shortener

> Transform YouTube links into smart short links that bypass in-app browsers and open directly in native apps.

## 🎯 What is OpenRight?

OpenRight is a minimalist mobile app that creates intelligent shortened links. When shared on social platforms like Instagram or Facebook, these links automatically open in the YouTube app instead of frustrating in-app browsers.

**Perfect for**: Content creators, marketers, and anyone who shares YouTube content frequently.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.5.0+ installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Node.js 20+ installed
- Cloudflare account (free tier works!)
- iOS/Android device or emulator

### Installation

1. **Install Flutter app dependencies**
```bash
flutter pub get
```

2. **Set up backend**
```bash
cd backend
npm install
```

3. **Configure Cloudflare Workers**

First, create a KV namespace for storing links:
```bash
cd backend
npx wrangler kv:namespace create "LINKS"
npx wrangler kv:namespace create "LINKS" --preview
```

This will output namespace IDs. Copy them into `backend/wrangler.toml`:
```toml
[[kv_namespaces]]
binding = "LINKS"
id = "YOUR_KV_NAMESPACE_ID_HERE"  # Replace with actual ID

[env.development]
[[env.development.kv_namespaces]]
binding = "LINKS"
preview_id = "YOUR_PREVIEW_KV_NAMESPACE_ID_HERE"  # Replace with actual preview ID
```

### Running Locally

**Terminal 1 - Backend (Cloudflare Workers)**
```bash
cd backend
npm run dev
```
This starts the Cloudflare Workers development server on `http://localhost:8787`

**Terminal 2 - Flutter Mobile App**
```bash
# Start Flutter app on emulator
flutter run -d emulator-5554

# Or for physical device
flutter run
```

## 📂 Project Structure

```
OpenRight/
├── lib/                      # Flutter application source
│   ├── main.dart             # App entry point
│   ├── screens/              
│   │   ├── home_screen.dart  # Main URL input screen
│   │   └── link_generated_screen.dart  # Success screen
│   ├── services/
│   │   └── api_service.dart  # API client for backend
│   └── utils/
│       └── url_helpers.dart  # YouTube URL validation
├── backend/
│   ├── worker.js             # Cloudflare Workers main file
│   └── wrangler.toml         # Workers configuration
├── android/                  # Android platform files
├── ios/                      # iOS platform files
└── pubspec.yaml              # Flutter dependencies
```

## 🎨 Design Philosophy

OpenRight follows a **minimalist, creator-first** design:

- **One primary action per screen** - No clutter
- **Zero learning curve** - Obvious on first use
- **Fast** - Link creation is instant
- **Trustworthy** - Clean, professional aesthetic
- **Invisible technology** - It just works

## 🔧 How It Works

### 1. User Flow
```
User pastes YouTube URL 
  → App validates URL
  → Sends to Cloudflare Workers
  → Receives short link
  → User copies/shares
```

### 2. Redirect Flow
```
User clicks short link (e.g., in Instagram)
  → Cloudflare Workers serves redirect page
  → JavaScript detects platform (iOS/Android)
  → Attempts deep link to YouTube app
  → Falls back to manual button if needed
```

### 3. Technology Stack

**Frontend (Mobile)**
- Flutter + Dart
- React Navigation
- Axios for API calls

**Backend**
- Cloudflare Workers (serverless edge computing)
- Workers KV (key-value storage for links)
- Native Web APIs (no external dependencies)

**Why Cloudflare Workers?**
- ✅ Free tier: 100,000 requests/day
- ✅ Globally distributed (fast everywhere)
- ✅ Zero cold starts
- ✅ Built-in KV storage
- ✅ No server management

## 🧪 Testing

### Test YouTube URL Shortening

1. Start both backend and mobile app
2. In the app, paste: `https://youtube.com/watch?v=dQw4w9WgXcQ`
3. Tap "Create Smart Link"
4. Copy the generated link
5. Open it in a browser or share via Instagram

### Test Deep Linking

**On Physical Device (Recommended)**
1. Generate a short link in the app
2. Share it via Instagram DM to yourself
3. Open the link from Instagram
4. Should automatically open YouTube app (or show button)

**Testing URL Patterns**
```javascript
// Valid URLs
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://m.youtube.com/watch?v=dQw4w9WgXcQ

// Invalid (will be rejected)
https://vimeo.com/123456
https://youtube.com (no video ID)
```

## 📱 Development Tips

### Using on Physical Device

1. **Same Network**: Ensure phone and computer are on same WiFi
2. **Update API URL**: In `src/services/api.js`, you may need to use your computer's local IP instead of `localhost`:
```javascript
const API_BASE_URL = __DEV__ 
  ? 'http://192.168.1.XXX:8787'  // Replace with your local IP
  : 'https://your-worker.workers.dev';
```

3. **Find your local IP**:
   - Mac: `ifconfig | grep "inet " | grep -v 127.0.0.1`
   - The Expo dev server will also show you the IP

### Debugging

- **Backend logs**: Watch the terminal running `npm run dev` in backend folder
- **Mobile logs**: Use Flutter DevTools or `print()` statements
- **Network requests**: Use Chrome DevTools or Reactotron

## 🚀 Deployment

### Deploy Backend to Cloudflare

```bash
cd backend
npx wrangler login
npx wrangler deploy
```

This gives you a production URL like: `https://openright-worker.your-subdomain.workers.dev`

Update `src/services/api.js` with your production URL:
```javascript
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:8787'
  : 'https://openright-worker.your-subdomain.workers.dev';
```

### Build Mobile App

**Android APK**
```bash
eas build --platform android --profile preview
```

**iOS IPA**
```bash
eas build --platform ios --profile preview
```

## 📊 Current Features (MVP v1)

- ✅ YouTube URL validation
- ✅ URL shortening with 6-character codes
- ✅ Platform detection (iOS/Android)
- ✅ Deep linking to YouTube app
- ✅ Graceful fallback with manual button
- ✅ Copy to clipboard
- ✅ Native share sheet
- ✅ Silent analytics tracking (future use)

## 🎯 Future Enhancements

- [ ] Custom short domains (e.g., `oprt.link`)
- [ ] Analytics dashboard
- [ ] Support for more platforms (Vimeo, Spotify, etc.)
- [ ] QR code generation
- [ ] Link expiration options
- [ ] User accounts (optional)
- [ ] Custom branded redirect pages

## 🤝 Contributing

This is currently a development-only MVP. Feel free to fork and extend!

## 📄 License

MIT License - feel free to use this however you'd like!

---

**Built with ❤️ for creators who deserve better link sharing**
