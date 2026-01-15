# 🚀 ngrok - Quick External Access (No Port Forwarding Needed!)

## ⚡ Fastest Solution for Testing

**ngrok** creates a secure tunnel to your local server, giving you a public URL **instantly** - no router configuration needed!

---

## 📦 Installation

### **Option 1: Snap (Recommended)**
```bash
sudo snap install ngrok
```

### **Option 2: Download**
```bash
# Download
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# Extract
tar xvzf ngrok-v3-stable-linux-amd64.tgz

# Move to PATH
sudo mv ngrok /usr/local/bin/
```

### **Option 3: npm**
```bash
npm install -g ngrok
```

---

## 🔧 Setup (30 seconds)

### **Step 1: Sign Up (Free)**
Visit: https://dashboard.ngrok.com/signup

### **Step 2: Get Auth Token**
After signup, copy your auth token from:
https://dashboard.ngrok.com/get-started/your-authtoken

### **Step 3: Configure**
```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN_HERE
```

---

## 🚀 Usage

### **Start ngrok Tunnel**

```bash
# Make sure your backend is running first!
# Then in a new terminal:
ngrok http 3000
```

**You'll see output like:**
```
ngrok

Session Status                online
Account                       your-email@example.com
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123xyz.ngrok-free.app -> http://localhost:3000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**Copy the HTTPS URL:** `https://abc123xyz.ngrok-free.app`

---

## 📱 Update Flutter App

### **Option 1: Use Environment Config (Recommended)**

Edit `flutter_app/lib/core/config/environment.dart`:

```dart
// Change this line:
static const String? cloudUrl = 'https://abc123xyz.ngrok-free.app';  // Your ngrok URL
```

**Then hot reload:**
```bash
# In your Flutter terminal, press:
R  # (capital R for hot restart)
```

### **Option 2: Quick Test**

You can also temporarily change:
```dart
static const String publicIp = 'abc123xyz.ngrok-free.app';
static const int port = 443;  // ngrok uses HTTPS (port 443)
```

---

## ✅ Test It!

1. **Start backend:**
   ```bash
   cd /home/iteck/Dev_Projects/webrtc_sample/backend
   npm run dev
   ```

2. **Start ngrok:**
   ```bash
   ngrok http 3000
   ```

3. **Update app with ngrok URL**

4. **Hot reload app** (press 'R')

5. **Test from mobile data:**
   - Turn OFF WiFi
   - Use mobile data
   - Open app
   - Register/Login should work!

---

## 🎯 Advantages

✅ **No router configuration needed**
✅ **Works immediately**
✅ **HTTPS included** (secure!)
✅ **Free tier available**
✅ **Perfect for testing**
✅ **Works from anywhere**

---

## ⚠️ Limitations

❌ **URL changes on restart** (free tier)
❌ **Session timeout** (8 hours on free tier)
❌ **Not for production** (use cloud deployment)
❌ **Slight latency** (traffic goes through ngrok servers)

---

## 💰 Pricing

**Free Tier:**
- ✅ 1 online ngrok process
- ✅ 40 connections/minute
- ✅ HTTPS included
- ⚠️ Random URL (changes on restart)

**Paid ($8/month):**
- ✅ Custom domains
- ✅ Reserved URLs (don't change)
- ✅ More connections
- ✅ Multiple tunnels

**For testing, free tier is perfect!**

---

## 🔄 Full Workflow

### **Terminal 1: Backend**
```bash
cd /home/iteck/Dev_Projects/webrtc_sample/backend
npm run dev
```

### **Terminal 2: ngrok**
```bash
ngrok http 3000
# Copy the HTTPS URL
```

### **Terminal 3: Flutter App**
```bash
cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app

# Edit environment.dart with ngrok URL
nano lib/core/config/environment.dart
# Set: cloudUrl = 'https://your-ngrok-url.ngrok-free.app'

# Run app
flutter run
```

---

## 🐛 Troubleshooting

### **Issue: "ngrok not found"**
```bash
# Install via snap
sudo snap install ngrok

# Or download and install manually
```

### **Issue: "Authentication failed"**
```bash
# Add your auth token
ngrok config add-authtoken YOUR_TOKEN
```

### **Issue: "tunnel not found"**
```bash
# Make sure backend is running first
curl http://localhost:3000/api/health

# Then start ngrok
ngrok http 3000
```

### **Issue: "Visit site" button on mobile**
**ngrok free tier shows a warning page first**

Solution:
- Click "Visit Site" button
- Or upgrade to paid plan ($8/month)
- Or use for development only

---

## 🚀 After Testing

Once you verify everything works with ngrok, you can:

1. **Set up port forwarding** (see PORT_FORWARDING_GUIDE.md)
2. **Deploy to cloud** (Railway, Heroku, DigitalOcean)

**ngrok proves your app works externally!**

---

## 📋 Quick Command Reference

```bash
# Install
sudo snap install ngrok

# Configure
ngrok config add-authtoken YOUR_TOKEN

# Start tunnel
ngrok http 3000

# Check status
curl http://localhost:4040/api/tunnels

# Stop
Ctrl+C
```

---

## 🎓 How It Works

```
Mobile Device (Mobile Data)
         ↓
    Internet
         ↓
ngrok Cloud (https://abc.ngrok-free.app)
         ↓
    ngrok Client (your computer)
         ↓
Backend Server (localhost:3000)
```

**ngrok creates a secure tunnel from the internet to your local server!**

---

**This is the FASTEST way to test external access without any router configuration!**

**Install ngrok and you'll be testing in 2 minutes!** ⚡
