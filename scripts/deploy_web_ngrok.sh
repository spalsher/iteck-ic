#!/bin/bash

# Deploy Flutter Web App via ngrok
# This creates an instant public URL with HTTPS

set -e

echo "🚀 Deploying Flutter Web App via ngrok..."
echo "================================================"
echo ""

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "📦 ngrok not found. Installing..."
    sudo snap install ngrok
    echo "✅ ngrok installed"
fi

# Check if ngrok is configured
if ! ngrok config check &> /dev/null; then
    echo "⚠️  ngrok not configured!"
    echo ""
    echo "Please follow these steps:"
    echo "1. Sign up at: https://dashboard.ngrok.com/signup"
    echo "2. Get your auth token from: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "3. Run: ngrok config add-authtoken YOUR_AUTH_TOKEN"
    echo ""
    exit 1
fi

echo "✅ ngrok is installed and configured"
echo ""

# Check if Flutter web app is running
if ! netstat -tuln | grep -q ":8080"; then
    echo "⚠️  Flutter web app is not running on port 8080"
    echo ""
    echo "Please start it first:"
    echo "  cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app"
    echo "  flutter run -d chrome --web-port 8080"
    echo ""
    exit 1
fi

echo "✅ Flutter web app is running on port 8080"
echo ""

echo "🌐 Starting ngrok tunnel..."
echo ""
echo "This will create a public URL for your web app."
echo "The URL will be displayed below."
echo ""
echo "⚠️  Note: Free tier shows a 'Visit site' button - this is normal"
echo "⚠️  Note: URL will change when you restart ngrok"
echo ""
echo "Press Ctrl+C to stop the tunnel"
echo ""
echo "================================================"
echo ""

# Start ngrok
ngrok http 8080
