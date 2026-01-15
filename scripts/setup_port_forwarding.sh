#!/bin/bash

# Setup firewall for web app port forwarding
# This prepares your system for port forwarding on port 8080

set -e

echo "🔥 Configuring Firewall for Web App (Port 8080)..."
echo "================================================"
echo ""

# Check if UFW is available
if command -v ufw &> /dev/null; then
    echo "✅ UFW detected"
    echo "Opening port 8080/tcp..."
    sudo ufw allow 8080/tcp
    sudo ufw reload
    echo "✅ UFW rule added"
    echo ""
    echo "Current UFW status:"
    sudo ufw status | grep 8080
elif command -v iptables &> /dev/null; then
    echo "✅ iptables detected"
    echo "Opening port 8080/tcp..."
    sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null 2>&1 || true
    echo "✅ iptables rule added"
    echo ""
    echo "Current rules:"
    sudo iptables -L -n | grep 8080 || echo "Rule added (may not show in list)"
else
    echo "⚠️  No firewall detected or already disabled"
fi

echo ""
echo "================================================"
echo "✅ Firewall configuration complete!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Configure Port Forwarding on Your Router:"
echo "   - Open: http://192.168.18.1"
echo "   - Login with router credentials"
echo "   - Find: Port Forwarding section"
echo "   - Add rule:"
echo "     Service Name: WebRTC Web App"
echo "     External Port: 8080"
echo "     Internal IP: 192.168.18.199"
echo "     Internal Port: 8080"
echo "     Protocol: TCP"
echo "   - Save and apply"
echo ""
echo "2. Test Access:"
echo "   Local:  http://localhost:8080"
echo "   LAN:    http://192.168.18.199:8080"
echo "   Public: http://154.57.197.59:8080"
echo ""
echo "================================================"
