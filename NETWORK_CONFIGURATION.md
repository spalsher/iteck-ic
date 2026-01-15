# Network Configuration Guide

## ✅ Smart Environment System Implemented

Your app now has a **centralized configuration system** that makes it easy to switch between different network environments!

### 📁 Configuration File

**`flutter_app/lib/core/config/environment.dart`**

This single file controls all network URLs in your app.

---

## 🎯 How to Use

### **For Local WiFi Testing (Current Setup)**

```dart
// In environment.dart
static const bool useLocalNetwork = true;  // ✅ Already set
```

**Works when:**
- Your phone is on the same WiFi as your computer
- Testing during development
- No router configuration needed

---

### **For Mobile Data / External Testing**

```dart
// In environment.dart
static const bool useLocalNetwork = false;  // Change to false
```

**Requirements:**
1. Configure firewall: `./FIREWALL_SETUP.sh`
2. Set up port forwarding on router (port 3000 → 192.168.18.199)
3. Turn OFF WiFi on phone, use mobile data
4. App will use public IP: 154.57.197.59

---

### **For Cloud Deployment (Production)**

```dart
// In environment.dart
static const String? cloudUrl = 'https://your-app.railway.app';  // Set your cloud URL
```

**When you deploy to:**
- Railway.app
- Heroku
- DigitalOcean
- Any cloud provider

Just set the `cloudUrl` and the app automatically uses it!

---

## 🔧 Quick Reference

### Current Settings:

| Setting | Value | Purpose |
|---------|-------|---------|
| `useLocalNetwork` | `true` | Use local WiFi |
| `localIp` | `192.168.18.199` | Your computer's IP |
| `publicIp` | `154.57.197.59` | Your public IP |
| `cloudUrl` | `null` | Cloud URL (when deployed) |
| `port` | `3000` | Backend port |

### Auto-Generated URLs:

```dart
Environment.baseUrl    // → http://192.168.18.199:3000/api
Environment.socketUrl  // → http://192.168.18.199:3000
```

---

## 🚀 Switching Environments

### **1. Development (Same WiFi)**
```dart
useLocalNetwork = true;
cloudUrl = null;
```
✅ Fast, no configuration needed

### **2. Testing External Access**
```dart
useLocalNetwork = false;
cloudUrl = null;
```
⚠️ Requires port forwarding

### **3. Production (Cloud)**
```dart
cloudUrl = 'https://your-app.railway.app';
// useLocalNetwork is ignored when cloudUrl is set
```
✅ Works everywhere, HTTPS enabled

---

## 📱 Testing Checklist

### **Local WiFi (Current)**
- [x] Phone on same WiFi
- [x] Backend running
- [x] `useLocalNetwork = true`
- [x] Test: Register, login, chat, calls

### **Mobile Data**
- [ ] Set `useLocalNetwork = false`
- [ ] Run `./FIREWALL_SETUP.sh`
- [ ] Configure router port forwarding
- [ ] Turn OFF WiFi on phone
- [ ] Test from mobile data

### **Cloud Deployment**
- [ ] Deploy backend to cloud
- [ ] Set `cloudUrl` in environment.dart
- [ ] Rebuild app
- [ ] Test from anywhere

---

## 🐛 Debugging

The app now prints configuration on startup:

```
🌐 Environment: Local WiFi
📡 Base URL: http://192.168.18.199:3000/api
🔌 Socket URL: http://192.168.18.199:3000
```

Check your terminal/console to see which environment is active!

---

## ⚠️ Why Public IP Doesn't Work from Local Network

**NAT Hairpinning Issue:**
- You **cannot** access your own public IP from inside your local network
- This is a router limitation, not a bug
- Solution: Use local IP when on same WiFi, public IP only from external networks

**Example:**
```
From your WiFi:
  ❌ http://154.57.197.59:3000 → Connection refused
  ✅ http://192.168.18.199:3000 → Works!

From mobile data:
  ✅ http://154.57.197.59:3000 → Works (with port forwarding)
  ❌ http://192.168.18.199:3000 → Not accessible
```

---

## 🎯 Recommended Setup

### **Development:**
```
useLocalNetwork = true
→ Fast, easy, no configuration
```

### **Production:**
```
Deploy to Railway/Heroku/DigitalOcean
Set cloudUrl
→ Works everywhere, professional setup
```

---

## 🔄 How to Switch

1. **Edit** `flutter_app/lib/core/config/environment.dart`
2. **Change** the settings (see examples above)
3. **Hot restart** the app (press 'R' in terminal)
4. **Verify** the printed configuration

---

## 📋 Current Status

✅ Environment system implemented
✅ All services updated to use Environment class
✅ Configuration prints on app startup
✅ Currently set to: **Local WiFi (192.168.18.199)**
✅ Backend listening on 0.0.0.0:3000 (accepts all connections)

**Your app is ready to work in any environment - just change the config!**
