# ⚡ Quick Port Forwarding Setup

## 🎯 What You Need to Do

Your app is **already configured** for external access. You just need to **configure your router** to allow external connections.

---

## 🔧 3-Minute Setup

### **Step 1: Find Your Router**

Your router IP is likely: **192.168.18.1**

Open in browser:
- http://192.168.18.1
- Or try: http://192.168.1.1
- Or try: http://192.168.0.1

### **Step 2: Login**

Try these common credentials:
- `admin` / `admin`
- `admin` / `password`
- Check sticker on router

### **Step 3: Find Port Forwarding**

Look for menu called:
- "Port Forwarding"
- "Virtual Server"
- "NAT"
- "Advanced Settings"

### **Step 4: Add This Rule**

```
Service Name: WebRTC
External Port: 3000
Internal IP: 192.168.18.199
Internal Port: 3000
Protocol: TCP
```

### **Step 5: Save & Apply**

Click Save/Apply. Router may restart.

### **Step 6: Configure Firewall**

```bash
cd /home/iteck/Dev_Projects/webrtc_sample
./FIREWALL_SETUP.sh
```

---

## ✅ Done!

Your app should now work from mobile data!

**Test it:**
1. Turn OFF WiFi on phone
2. Use mobile data only
3. Open app and try to login

---

## 🚨 Can't Access Router?

**Alternative: Use ngrok (Quick Test)**

```bash
# Install ngrok
snap install ngrok

# Expose port 3000
ngrok http 3000

# Copy the URL (e.g., https://abc123.ngrok.io)
# Update environment.dart:
cloudUrl = 'https://abc123.ngrok.io'

# Hot reload app
```

**Note:** ngrok URLs change on restart. For production, use cloud deployment.

---

## 🚀 Best Solution: Deploy to Cloud

**Railway.app (5 minutes):**

```bash
# Install
npm install -g @railway/cli

# Login
railway login

# Deploy
cd backend
railway init
railway up

# Get URL and update app
railway domain
```

**No port forwarding needed!**
**HTTPS included!**
**Works everywhere!**

---

## 📋 Current Status

✅ App configured: `http://154.57.197.59:3000`
✅ Backend running
⚠️ **Waiting for port forwarding**

**Choose your path:**
1. **Port forwarding** (5 minutes, free, requires router access)
2. **ngrok** (1 minute, free, temporary URLs)
3. **Cloud deployment** (5 minutes, $5/month, professional)
