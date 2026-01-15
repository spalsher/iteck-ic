#!/bin/bash

# Firewall Configuration Script for WebRTC Backend
# This script opens port 3000 for public access

echo "🔥 Configuring Firewall for WebRTC Backend..."
echo "================================================"
echo ""

# Check if UFW is available
if command -v ufw &> /dev/null; then
    echo "✅ UFW detected"
    echo "Opening port 3000/tcp..."
    sudo ufw allow 3000/tcp
    sudo ufw reload
    echo "✅ UFW rule added"
    echo ""
    echo "Current UFW status:"
    sudo ufw status
elif command -v iptables &> /dev/null; then
    echo "✅ iptables detected"
    echo "Opening port 3000/tcp..."
    sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
    sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
    echo "✅ iptables rule added and saved"
    echo ""
    echo "Current rules:"
    sudo iptables -L -n | grep 3000
else
    echo "⚠️  No firewall detected or already disabled"
fi

echo ""
echo "================================================"
echo "🎉 Firewall configuration complete!"
echo ""
echo "Test your backend:"
echo "  Local:  curl http://localhost:3000/api/health"
echo "  Public: curl http://154.57.197.59:3000/api/health"
echo ""
echo "⚠️  Don't forget to configure port forwarding on your router!"
echo "================================================"
