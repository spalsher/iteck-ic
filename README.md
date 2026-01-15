# WebRTC Chat Application

A full-stack cross-platform chat application with WebRTC for voice/video calls and P2P messaging. Features a modern glassmorphic UI design with responsive layouts.

## 🚀 Features

### Communication
- 📞 **Voice Calls** - High-quality peer-to-peer voice calls
- 📹 **Video Calls** - HD video calling with camera controls
- 💬 **Real-time Chat** - P2P messaging via WebRTC data channels
- 📸 **Media Sharing** - Send images and videos
- 🔔 **Call Notifications** - Incoming call alerts

### User Experience
- 🎨 **Glassmorphic UI** - Modern frosted glass design effect
- 🌈 **Cyan/White Theme** - Clean and professional color scheme
- 📱 **Responsive Design** - Optimized for phones, tablets, and desktops
- ⚡ **Real-time Updates** - Live online/offline status
- 🔍 **Contact Search** - Find users by username
- 📲 **QR Code Sharing** - Add contacts by scanning QR codes

### Security & Performance
- 🔐 **JWT Authentication** - Secure user authentication
- 🔒 **Encrypted Connections** - DTLS/SRTP for WebRTC
- ⚡ **P2P Architecture** - Direct peer-to-peer communication
- 🚀 **Optimized Media** - Automatic image/video compression
- 🔄 **Auto Reconnection** - Reliable connection handling

## 📋 Tech Stack

### Frontend (Flutter)
- Flutter 3.19.0+
- flutter_webrtc for WebRTC
- socket_io_client for signaling
- Provider for state management
- Material Design 3

### Backend (Node.js)
- Express.js
- Socket.io for WebRTC signaling
- MongoDB with Mongoose
- JWT authentication
- Multer for file uploads

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Flutter App    │◄───────►│  Node.js Backend │◄───────►│   MongoDB       │
│  (Frontend)     │  HTTP   │  (Express +      │          │   (Database)    │
│                 │  +WS    │   Socket.io)     │          │                 │
└─────────────────┘         └──────────────────┘          └─────────────────┘
       │                            │
       │                            │
       └────────── WebRTC ──────────┘
            (P2P Connection)
```

## 📦 Project Structure

```
webrtc_sample/
├── backend/                 # Node.js backend
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── models/         # Database models
│   │   ├── routes/         # API routes
│   │   ├── socket/         # WebRTC signaling
│   │   ├── middleware/     # Auth middleware
│   │   └── utils/          # Utilities
│   ├── uploads/            # Media storage
│   └── package.json
│
└── flutter_app/            # Flutter frontend
    ├── lib/
    │   ├── core/           # Core functionality
    │   ├── features/       # App features
    │   └── shared/         # Shared widgets
    ├── assets/
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites

- **Backend:**
  - Node.js 18.x or 20.x LTS
  - MongoDB 6.0+
  - npm 9.x+

- **Frontend:**
  - Flutter SDK 3.19.0+
  - Dart 3.3.0+
  - Android Studio (for Android)
  - Xcode 15.0+ (for iOS)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/webrtc_chat
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_EXPIRE=7d
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=image/jpeg,image/png,image/gif,video/mp4,video/webm
CORS_ORIGIN=*
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX=100
```

4. Start MongoDB (if running locally):
```bash
mongod
```

5. Run the server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

### Flutter App Setup

1. Navigate to flutter_app directory:
```bash
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. For iOS, install CocoaPods:
```bash
cd ios
pod install
cd ..
```

4. Run the app:
```bash
flutter run
```

## 📱 Platform-Specific Configuration

### Android

Update `android/app/build.gradle`:
```gradle
minSdkVersion 21
targetSdkVersion 34
compileSdkVersion 34
```

### iOS

Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh token

### Users
- `GET /api/users/me` - Get current user
- `GET /api/users/search` - Search users
- `GET /api/users/:id` - Get user by ID
- `GET /api/users/:id/qr` - Get user QR code
- `POST /api/users/contacts/:userId` - Add contact
- `DELETE /api/users/contacts/:userId` - Remove contact

### Media
- `POST /api/media/upload` - Upload media
- `GET /api/media/:filename` - Get media file
- `DELETE /api/media/:filename` - Delete media

### Socket.io Events
- `call-request` - Initiate call
- `call-accept` - Accept call
- `call-reject` - Reject call
- `call-end` - End call
- `offer` - WebRTC offer
- `answer` - WebRTC answer
- `ice-candidate` - ICE candidate
- `message` - Text message

## 🎨 Design System

### Colors
- Primary Cyan: `#00BCD4`
- Dark Cyan: `#00ACC1`
- Light Cyan: `#B2EBF2`
- White: `#FFFFFF`
- Light Gray: `#F5F5F5`

### Glassmorphic Effect
- Backdrop blur: 20-30px
- Background opacity: 0.1-0.3
- Border: 1px solid with gradient
- Soft shadows
- Border radius: 20-30px

## 🧪 Testing

### Backend
```bash
cd backend
npm test
```

### Flutter
```bash
cd flutter_app
flutter test
```

## 📦 Building for Production

### Backend
```bash
cd backend
npm start
```

### Flutter

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🚀 Deployment

### Backend Deployment Options
- AWS EC2
- DigitalOcean
- Heroku
- Render
- Railway

### Database
- MongoDB Atlas (recommended for production)
- Self-hosted MongoDB

### Mobile App Distribution
- Google Play Store (Android)
- Apple App Store (iOS)

## 🔒 Security Considerations

- Use strong JWT secrets in production
- Enable HTTPS/WSS for all connections
- Implement rate limiting
- Validate all user inputs
- Use TURN servers for production WebRTC
- Regular security audits
- Keep dependencies updated

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please create an issue in the repository.

## 🙏 Acknowledgments

- Flutter WebRTC team
- Socket.io team
- Express.js team
- MongoDB team

---

Made with ❤️ using Flutter and Node.js
