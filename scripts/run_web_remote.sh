#!/bin/bash

# Run Flutter Web App with Remote Access
# Makes the app accessible from any device on your network

set -e

echo "🌐 Starting Flutter Web App (Remote Access)..."
echo "================================================"
echo ""

cd /home/iteck/Dev_Projects/webrtc_sample/flutter_app

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found"
    echo "Please install Flutter first"
    exit 1
fi

echo "✅ Flutter found"
echo ""

# Get local IP
LOCAL_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
echo "📍 Your Local IP: $LOCAL_IP"
echo ""

# Default port
PORT=${1:-8000}

echo "🚀 Starting Flutter web app on port $PORT..."
echo "🌐 Binding to all interfaces (0.0.0.0)"
echo ""
echo "Access URLs:"
echo "  Local:      http://localhost:$PORT"
echo "  Network:    http://$LOCAL_IP:$PORT"
echo "  Public:     http://154.57.197.59:$PORT (if port forwarded)"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "================================================"
echo ""

# Run Flutter with remote access enabled
flutter run -d chrome --web-hostname 0.0.0.0 --web-port $PORT
