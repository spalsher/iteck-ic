# 🌐 Port Forwarding Setup Guide

## ✅ App Configuration Updated

Your Flutter app is now configured for **external access**:
- 🌐 Environment: **External/Mobile Data**
- 📡 Base URL: **http://154.57.197.59:3000/api**
- 🔌 Socket URL: **http://154.57.197.59:3000**

---

## ⚠️ Critical: Port Forwarding Required

For devices on mobile data (GSM internet) to access your backend, you **must** configure port forwarding on your router.

### What is Port Forwarding?

Port forwarding tells your router to forward external requests on port 3000 to your computer's internal IP (192.168.18.199).

```
Internet (154.57.197.59:3000)
         ↓
    Your Router
         ↓ (Port Forward)
Your Computer (192.168.18.199:3000)
         ↓
    Backend Server
```

---

## 🔧 Step-by-Step Setup

### **Step 1: Find Your Router's Admin Panel**

**Common router addresses:**
- http://192.168.1.1
- http://192.168.0.1
- http://192.168.18.1 (likely yours)
- http://10.0.0.1

**How to find it:**
```bash
ip route | grep default
# Output shows your gateway (router IP)
```

### **Step 2: Login to Router**

**Common default credentials:**
- Username: `admin` / Password: `admin`
- Username: `admin` / Password: `password`
- Check the sticker on your router
- Check your ISP documentation

### **Step 3: Find Port Forwarding Section**

**Look for these menu names:**
- "Port Forwarding"
- "Virtual Server"
- "NAT Forwarding"
- "Applications & Gaming"
- "Advanced Settings" → "Port Forwarding"

### **Step 4: Create Port Forward Rule**

**Add a new rule with these settings:**

| Setting | Value |
|---------|-------|
| **Service Name** | WebRTC Backend |
| **External Port** | 3000 |
| **Internal IP** | 192.168.18.199 |
| **Internal Port** | 3000 |
| **Protocol** | TCP (or Both TCP/UDP) |
| **Status** | Enabled |

**Example configurations for popular routers:**

#### **TP-Link:**
```
Service Type: Custom
Service Name: WebRTC
External Port: 3000
Internal IP: 192.168.18.199
Internal Port: 3000
Protocol: TCP
Status: Enabled
```

#### **Netgear:**
```
Service Name: WebRTC
Server IP Address: 192.168.18.199
External Port Range: 3000 - 3000
Internal Port Range: 3000 - 3000
Protocol: TCP
```

#### **D-Link:**
```
Name: WebRTC
IP Address: 192.168.18.199
Public Port: 3000
Private Port: 3000
Protocol: TCP
Schedule: Always
```

#### **Asus:**
```
Service Name: WebRTC
Port Range: 3000
Local IP: 192.168.18.199
Local Port: 3000
Protocol: TCP
```

### **Step 5: Save and Apply**

1. Click **Save** or **Apply**
2. Router may restart (wait 1-2 minutes)
3. Port forwarding is now active

---

## 🔥 Configure Firewall

Run the firewall setup script:

```bash
cd /home/iteck/Dev_Projects/webrtc_sample
./FIREWALL_SETUP.sh
```

Or manually:

```bash
# Ubuntu/Debian with UFW
sudo ufw allow 3000/tcp
sudo ufw reload
sudo ufw status

# Or with iptables
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
sudo iptables-save
```

---

## 🧪 Testing

### **Test 1: Local Access (Should Work)**
```bash
curl http://192.168.18.199:3000/api/health
```
**Expected:** `{"success":true,"message":"Server is running",...}`

### **Test 2: Public Access (After Port Forwarding)**
```bash
curl http://154.57.197.59:3000/api/health
```
**Expected:** `{"success":true,"message":"Server is running",...}`

### **Test 3: From Mobile Device**

**On WiFi:**
- Turn OFF WiFi
- Use mobile data only
- Open your app
- Try to register/login

**Expected:** Should connect successfully!

---

## 🔍 Troubleshooting

### **Issue: "Connection refused" from public IP**

**Possible causes:**
1. ❌ Port forwarding not configured
2. ❌ Firewall blocking port 3000
3. ❌ Backend not running
4. ❌ Router not restarted after configuration

**Solutions:**
```bash
# Check if backend is running
curl http://localhost:3000/api/health

# Check if port is listening
netstat -tulpn | grep 3000

# Check firewall
sudo ufw status | grep 3000

# Restart router
# (Use router admin panel)
```

### **Issue: "Connection timeout"**

**Possible causes:**
1. ❌ ISP blocking port 3000
2. ❌ Router firewall enabled
3. ❌ Incorrect internal IP

**Solutions:**
- Try a different port (e.g., 8080)
- Check router firewall settings
- Verify internal IP: `ip addr show`

### **Issue: Works locally but not externally**

**This is the NAT hairpinning issue!**

You **cannot** test your public IP from inside your local network.

**Solution:**
- Test from actual mobile data (turn OFF WiFi)
- Or use an external testing service:
  ```bash
  # Test from external server
  ssh remote-server
  curl http://154.57.197.59:3000/api/health
  ```

---

## 🔐 Security Considerations

### **Current Setup (HTTP)**
- ⚠️ Unencrypted traffic
- ⚠️ Passwords sent in plain text
- ⚠️ Vulnerable to man-in-the-middle attacks

### **Recommendations:**

1. **Use HTTPS (Production)**
   - Get SSL certificate (Let's Encrypt)
   - Set up reverse proxy (Nginx)
   - Or deploy to cloud with HTTPS

2. **Keep Rate Limiting** (Already enabled)
   - Protects against brute force
   - Limits API abuse

3. **Strong JWT Secret**
   - Change default secret in `.env`
   - Use long, random string

4. **Monitor Logs**
   - Watch for suspicious activity
   - Set up alerts

---

## 🚀 Alternative: Cloud Deployment (Recommended)

Instead of port forwarding, deploy to cloud:

### **Option 1: Railway.app (Easiest)**
```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Deploy
cd /home/iteck/Dev_Projects/webrtc_sample/backend
railway init
railway up

# 4. Get URL
railway domain
# Example: https://webrtc-backend-production.up.railway.app
```

### **Option 2: DigitalOcean**
```bash
# 1. Create droplet ($6/month)
# 2. SSH into droplet
# 3. Clone and deploy
git clone your-repo
cd backend
npm install
npm start
```

### **Option 3: Heroku**
```bash
# 1. Install Heroku CLI
# 2. Deploy
heroku create your-app-name
git push heroku main
```

**Benefits:**
- ✅ HTTPS included
- ✅ No router configuration
- ✅ Better performance
- ✅ Professional setup
- ✅ Easy scaling

---

## 📋 Current Status

✅ Backend running on 0.0.0.0:3000
✅ Flutter app configured for external access (154.57.197.59)
✅ Environment prints confirm: "External/Mobile Data"
⚠️ **Port forwarding needed** (see steps above)
⚠️ **Firewall configuration needed** (run ./FIREWALL_SETUP.sh)

---

## 🎯 Quick Checklist

- [ ] Find router admin panel
- [ ] Login to router
- [ ] Navigate to Port Forwarding section
- [ ] Add rule: Port 3000 → 192.168.18.199:3000
- [ ] Save and apply
- [ ] Run `./FIREWALL_SETUP.sh`
- [ ] Test from mobile data
- [ ] Verify app connects successfully

---

## 📞 Need Help?

**Can't access router?**
- Contact your ISP
- Check router manual
- Look for sticker with default credentials

**ISP blocking ports?**
- Some ISPs block common ports
- Try port 8080 or 8443 instead
- Contact ISP to unblock

**Still not working?**
- Consider cloud deployment (Railway/Heroku)
- Much easier than port forwarding
- Professional and secure

---

**Once port forwarding is set up, your app will work from anywhere!** 🌍
