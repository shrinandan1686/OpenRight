# OpenRight - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Start the Backend Server

Open a new terminal and run:

```bash
cd backend
npx wrangler login  # First time only - authenticate with Cloudflare
./setup.sh         # Creates KV namespaces and configures wrangler.toml
npm run dev        # Starts server at http://localhost:8787
```

Leave this terminal running.

---

### 2. Start the Mobile App

Open another terminal and run:

```bash
npm start
```

You'll see a QR code. Scan it with:
- **iOS**: Camera app → Tap the notification
- **Android**: Expo Go app → Scan QR

Or press:
- `a` to open Android emulator
- `i` to open iOS simulator  
- `w` to open in web browser

---

### 3. Test the App

1. **On your device/emulator**, you'll see the OpenRight home screen
2. **Paste a YouTube URL**: `https://youtube.com/watch?v=dQw4w9WgXcQ`
3. **Tap "Create Smart Link"**
4. **Copy the generated link**
5. **Share it!** (Try sending via Instagram DM to test deep linking)

---

## 🐛 Troubleshooting

### "Cannot connect to backend"
- Ensure backend server is running: `cd backend && npm run dev`
- Check `src/services/api.js` - may need to use your computer's local IP instead of `localhost`
- Find your IP: Run `ifconfig | grep "inet " | grep -v 127.0.0.1` on Mac

### "Watchman error"
Fixed! We've configured Metro to use node crawler instead.

### "KV namespace error"
Run `cd backend && ./setup.sh` to create KV namespaces automatically.

---

## 📱 Testing Deep Links

**Best tested on a physical device:**

1. Generate a link in the app
2. Share via Instagram DM to yourself
3. Open the link from Instagram
4. Should open YouTube app (or show button to open it manually)

---

## 🎯 Next Steps

1. **Test locally** - Make sure everything works
2. **Deploy backend** - `cd backend && npx wrangler deploy`
3. **Get a domain** - Register a short domain like `oprt.link`
4. **Update app** - Point to production URL
5. **Build apps** - `eas build --platform android/ios`

---

## 📖 Full Documentation

See [README.md](file:///Volumes/Shri&Shree%201/Projects/OpenRight/README.md) for comprehensive docs.

---

**Questions?** Check the walkthrough.md for implementation details.
