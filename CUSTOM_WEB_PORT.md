# 🔌 Custom Port for Flutter Web App

## 📋 Recommended Alternative Ports

Here are safe, commonly used ports for web development:

| Port | Common Use | Recommendation |
|------|------------|----------------|
| **8000** | Python SimpleHTTPServer | ✅ Great choice |
| **8888** | Jupyter Notebook | ✅ Great choice |
| **9000** | Various web apps | ✅ Great choice |
| **5000** | Flask/React dev | ✅ Good |
| **7000** | Various services | ✅ Good |
| **3001** | Next.js/React | ✅ Good |
| **4200** | Angular | ✅ Good |

**My Recommendation:** Use **port 8000** or **9000** - they're rarely used and easy to remember.

---

## 🚀 How to Use a Different Port

### **Run Flutter Web on Custom Port:**

```bash
cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app

# Use port 8000
flutter run -d chrome --web-port 8000

# Or port 9000
flutter run -d chrome --web-port 9000

# Or any port you want
flutter run -d chrome --web-port YOUR_PORT
```

---

## 🌐 Access URLs

### **If you choose port 8000:**
- Local: http://localhost:8000
- LAN: http://192.168.18.199:8000
- Public: http://154.57.197.59:8000

### **If you choose port 9000:**
- Local: http://localhost:9000
- LAN: http://192.168.18.199:9000
- Public: http://154.57.197.59:9000

---

## 🔧 Port Forwarding Setup

### **If you want external access:**

**Update firewall:**
```bash
# For port 8000
sudo ufw allow 8000/tcp
sudo ufw reload

# Or for port 9000
sudo ufw allow 9000/tcp
sudo ufw reload
```

**Router configuration:**
- Open: http://192.168.18.1
- Add port forwarding rule:
  - External Port: **8000** (or your chosen port)
  - Internal IP: **192.168.18.199**
  - Internal Port: **8000** (or your chosen port)
  - Protocol: **TCP**

---

## ⚡ ngrok with Custom Port

### **If using ngrok:**

```bash
# For port 8000
ngrok http 8000

# For port 9000
ngrok http 9000

# For any custom port
ngrok http YOUR_PORT
```

---

## 🔍 Check Port Availability

### **Before using a port, check if it's free:**

```bash
# Check specific port (e.g., 8000)
netstat -tuln | grep :8000

# If empty output = port is free ✅
# If shows something = port is in use ❌
```

### **Or use lsof:**
```bash
lsof -i :8000
```

---

## 📝 Quick Commands

### **Port 8000 (Recommended):**
```bash
# Run web app
cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app
flutter run -d chrome --web-port 8000

# Allow firewall
sudo ufw allow 8000/tcp

# ngrok tunnel
ngrok http 8000
```

### **Port 9000 (Alternative):**
```bash
# Run web app
cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app
flutter run -d chrome --web-port 9000

# Allow firewall
sudo ufw allow 9000/tcp

# ngrok tunnel
ngrok http 9000
```

---

## 🎯 Best Practices

### **Choose a port that:**
- ✅ Is above 1024 (doesn't require root)
- ✅ Is not commonly used by system services
- ✅ Is easy to remember
- ✅ Doesn't conflict with your other services

### **Ports to Avoid:**
- ❌ 80 (HTTP - requires root)
- ❌ 443 (HTTPS - requires root)
- ❌ 3000 (your backend is using this)
- ❌ 22 (SSH)
- ❌ 3306 (MySQL)
- ❌ 5432 (PostgreSQL)
- ❌ 27017 (MongoDB)

---

## 📊 Your Current Setup

**Current Ports:**
- Backend: **3000** ✅ In use
- Web App: **8080** ⏳ You want to change this

**Suggested New Port:**
- Web App: **8000** ✅ Recommended

**Updated Setup:**
- Backend: **3000**
- Web App: **8000**

---

## 🚀 Quick Start with Port 8000

```bash
# 1. Run web app on port 8000
cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app
flutter run -d chrome --web-port 8000

# 2. Access locally
# Open: http://localhost:8000

# 3. For external access (optional)
sudo ufw allow 8000/tcp
# Then configure router for port 8000

# 4. Or use ngrok
ngrok http 8000
```

---

**Port 8000 is free and recommended! Use it to avoid any conflicts.** 🎯
