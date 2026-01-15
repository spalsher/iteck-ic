---
name: Cross-Platform Chat App with WebRTC
overview: Build a cross-platform Flutter chat app with WebRTC for voice/video calls and P2P messaging, featuring glassmorphic UI design with cyan/white theme and responsive layouts. Backend will be Node.js with Express and Socket.io for signaling.
todos:
  - id: setup-backend
    content: Set up Node.js backend with Express, Socket.io, and MongoDB
    status: completed
  - id: implement-auth
    content: Implement authentication system with JWT
    status: completed
    dependencies:
      - setup-backend
  - id: setup-flutter
    content: Set up Flutter project structure with theme and navigation
    status: completed
  - id: implement-webrtc
    content: Implement WebRTC service and signaling logic
    status: completed
    dependencies:
      - setup-backend
      - setup-flutter
  - id: build-chat-ui
    content: Build chat UI with glassmorphic design and P2P messaging
    status: completed
    dependencies:
      - setup-flutter
      - implement-webrtc
  - id: implement-media
    content: Implement media upload/download and viewing
    status: completed
    dependencies:
      - implement-auth
      - build-chat-ui
  - id: implement-calls
    content: Implement voice and video calling functionality
    status: completed
    dependencies:
      - implement-webrtc
      - build-chat-ui
  - id: add-contacts
    content: Add contact management with QR code support
    status: completed
    dependencies:
      - implement-auth
  - id: polish-responsive
    content: Polish UI and implement responsive layouts
    status: completed
    dependencies:
      - build-chat-ui
      - implement-calls
  - id: testing-deployment
    content: Test, fix bugs, and deploy to production
    status: completed
    dependencies:
      - polish-responsive
      - implement-calls
      - implement-media
isProject: false
---

# Cross-Platform Chat App with WebRTC

## Architecture Overview

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Flutter App    │◄───────►│  Node.js Backend │◄───────►│   Database      │
│  (Frontend)     │  HTTP   │  (Express +      │          │   (MongoDB/     │
│                 │  +WS    │   Socket.io)     │          │    PostgreSQL)  │
└─────────────────┘         └──────────────────┘          └─────────────────┘
       │                            │
       │                            │
       └────────── WebRTC ──────────┘
            (P2P Connection)
```

## Tech Stack

**System Requirements:**

- Flutter SDK: 3.19.0 or higher (stable channel)
- Dart: 3.3.0 or higher
- Node.js: 18.x or 20.x LTS
- npm: 9.x or higher
- MongoDB: 6.0 or higher
- Android Studio (for Android): Latest stable
- Xcode (for iOS): 15.0 or higher
- Minimum Android API: 21 (Android 5.0)
- Minimum iOS: 12.0

**Frontend (Flutter):**

- `flutter_webrtc: ^0.9.48` - WebRTC implementation
- `socket_io_client: ^2.0.3+1` - Socket.io signaling
- `permission_handler: ^11.3.0` - Camera/mic permissions
- `image_picker: ^1.0.7` - Media selection
- `cached_network_image: ^3.3.1` - Image caching
- `provider: ^6.1.1` - State management
- `http: ^1.2.0` - HTTP requests
- `qr_flutter: ^4.1.0` - QR code generation
- `qr_code_scanner: ^1.0.1` - QR code scanning
- `shared_preferences: ^2.2.2` - Local storage
- `flutter_bloc: ^8.1.4` - Optional, for advanced state management
- `uuid: ^4.3.3` - Unique ID generation
- `intl: ^0.19.0` - Date/time formatting
- `video_player: ^2.8.2` - Video playback in chat
- `path_provider: ^2.1.2` - File path management
- `dio: ^5.4.0` - Advanced HTTP client for uploads

**Backend (Node.js):**

- `express: ^4.18.2` - Web framework
- `socket.io: ^4.6.1` - WebRTC signaling
- `mongoose: ^8.1.0` - MongoDB ODM
- `jsonwebtoken: ^9.0.2` - JWT authentication
- `bcryptjs: ^2.4.3` - Password hashing
- `multer: ^1.4.5-lts.1` - File uploads
- `qrcode: ^1.5.3` - QR code generation
- `cors: ^2.8.5` - CORS middleware
- `dotenv: ^16.4.1` - Environment variables
- `express-validator: ^7.0.1` - Input validation
- `helmet: ^7.1.0` - Security headers
- `express-rate-limit: ^7.1.5` - Rate limiting
- `morgan: ^1.10.0` - Request logging
- `compression: ^1.7.4` - Response compression
- `uuid: ^9.0.1` - Unique ID generation

## Project Structure

```
webrtc_sample/
├── backend/
│   ├── src/
│   │   ├── server.js           # Express server entry
│   │   ├── routes/
│   │   │   ├── auth.js          # Auth endpoints
│   │   │   ├── users.js         # User management
│   │   │   └── media.js         # Media upload
│   │   ├── controllers/
│   │   │   ├── authController.js
│   │   │   ├── userController.js
│   │   │   └── mediaController.js
│   │   ├── models/
│   │   │   └── User.js          # User model
│   │   ├── middleware/
│   │   │   └── auth.js          # JWT middleware
│   │   ├── socket/
│   │   │   └── signaling.js     # WebRTC signaling handlers
│   │   └── utils/
│   │       ├── qrGenerator.js
│   │       └── fileUpload.js
│   ├── uploads/                 # Media storage
│   ├── package.json
│   └── .env
│
└── flutter_app/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── theme/
    │   │   │   ├── app_colors.dart      # Cyan/white theme
    │   │   │   ├── glassmorphic.dart    # Glassmorphic widgets
    │   │   │   └── responsive.dart      # Media query utilities
    │   │   ├── services/
    │   │   │   ├── auth_service.dart
    │   │   │   ├── socket_service.dart  # Socket.io client
    │   │   │   ├── webrtc_service.dart  # WebRTC logic
    │   │   │   └── media_service.dart
    │   │   └── models/
    │   │       ├── user.dart
    │   │       ├── message.dart
    │   │       └── call_state.dart
    │   ├── features/
    │   │   ├── auth/
    │   │   │   ├── screens/
    │   │   │   │   ├── login_screen.dart
    │   │   │   │   └── register_screen.dart
    │   │   ├── chat/
    │   │   │   ├── screens/
    │   │   │   │   ├── chat_list_screen.dart
    │   │   │   │   ├── chat_screen.dart
    │   │   │   │   └── media_viewer_screen.dart
    │   │   │   ├── widgets/
    │   │   │   │   ├── message_bubble.dart
    │   │   │   │   ├── chat_input.dart
    │   │   │   │   └── media_picker.dart
    │   │   ├── calls/
    │   │   │   ├── screens/
    │   │   │   │   ├── incoming_call_screen.dart
    │   │   │   │   ├── active_call_screen.dart
    │   │   │   │   └── call_history_screen.dart
    │   │   │   └── widgets/
    │   │   │       ├── call_controls.dart
    │   │   │       └── video_view.dart
    │   │   └── contacts/
    │   │       ├── screens/
    │   │       │   ├── contacts_screen.dart
    │   │       │   ├── add_contact_screen.dart
    │   │       │   └── qr_scanner_screen.dart
    │   │       └── widgets/
    │   │           └── qr_code_widget.dart
    │   └── shared/
    │       └── widgets/
    │           ├── glassmorphic_container.dart
    │           └── responsive_wrapper.dart
    ├── pubspec.yaml
    └── assets/
        └── images/
```

## Implementation Details

### Backend Implementation

**1. Authentication System** (`backend/src/routes/auth.js`)

- POST `/api/auth/register` - User registration
- POST `/api/auth/login` - User login (returns JWT)
- POST `/api/auth/refresh` - Token refresh

**2. User Management** (`backend/src/routes/users.js`)

- GET `/api/users/search?username=xxx` - Search users
- GET `/api/users/:id` - Get user by ID
- GET `/api/users/:id/qr` - Generate QR code for user
- GET `/api/users/me` - Get current user

**3. Media Upload** (`backend/src/routes/media.js`)

- POST `/api/media/upload` - Upload image/video
- GET `/api/media/:filename` - Serve media files

**4. WebRTC Signaling** (`backend/src/socket/signaling.js`)

- Socket.io events:
                - `offer` - Send WebRTC offer
                - `answer` - Send WebRTC answer
                - `ice-candidate` - Exchange ICE candidates
                - `call-request` - Initiate call
                - `call-accept` - Accept call
                - `call-reject` - Reject call
                - `call-end` - End call
                - `message` - Text message via signaling (fallback)

### Flutter Implementation

**1. Theme & Design System**

- **Colors**: Cyan (#00BCD4, #00ACC1) and White (#FFFFFF, #F5F5F5)
- **Glassmorphic Effects**: 
                - Backdrop blur with opacity
                - Gradient borders
                - Shadow effects
                - Custom `GlassmorphicContainer` widget
- **Responsive Design**:
                - Media query utilities for screen sizes
                - Adaptive layouts for phones/tablets
                - Font scaling based on screen density

**2. Core Services**

**WebRTC Service** (`lib/core/services/webrtc_service.dart`):

- Peer connection management
- Media stream handling (audio/video)
- Data channel for P2P messaging
- ICE candidate exchange
- Call state management

**Socket Service** (`lib/core/services/socket_service.dart`):

- Socket.io connection
- Signaling event handlers
- Reconnection logic
- Event emission

**3. Key Features**

**Chat Screen**:

- Message bubbles with glassmorphic styling
- Image/video preview in chat
- Real-time message updates via WebRTC data channel
- Media picker integration
- Responsive input area

**Call Screens**:

- Incoming call with glassmorphic UI
- Active call with video grid
- Call controls (mute, video toggle, end)
- Picture-in-picture support
- Screen size adaptation

**Contact Discovery**:

- Username search
- User ID lookup
- QR code scanner (camera integration)
- QR code display for sharing

## Design Specifications

**Glassmorphic Style:**

```dart
- Backdrop blur: 20-30px
- Background opacity: 0.1-0.3
- Border: 1px solid with gradient
- Shadow: Soft, multi-layered
- Border radius: 20-30px
```

**Color Palette:**

- Primary Cyan: #00BCD4
- Dark Cyan: #00ACC1
- Light Cyan: #B2EBF2
- White: #FFFFFF
- Light Gray: #F5F5F5
- Dark Gray: #424242

**Responsive Breakpoints:**

- Small: < 360px
- Medium: 360px - 768px
- Large: 768px - 1024px
- XL: > 1024px

## Data Flow

### WebRTC Call Flow

```
User A                    Signaling Server              User B
  │                            │                          │
  ├─ call-request ────────────►│                          │
  │                            ├─ call-request ──────────►│
  │                            │                          │
  │                            │◄──── call-accept ────────┤
  │◄──── call-accept ──────────┤                          │
  │                            │                          │
  ├─ offer ───────────────────►│                          │
  │                            ├─ offer ─────────────────►│
  │                            │                          │
  │                            │◄──── answer ─────────────┤
  │◄──── answer ───────────────┤                          │
  │                            │                          │
  ├─ ice-candidate ────────────►│                          │
  │                            ├─ ice-candidate ──────────►│
  │                            │                          │
  │◄──── ice-candidate ─────────┤                          │
  │                            │                          │
  └────────── P2P Connection Established ─────────────────┘
```

### Message Flow (P2P via Data Channel)

```
User A                    WebRTC Data Channel            User B
  │                                                         │
  ├─ message ────────────────────────────────────────────►│
  │                                                         │
  │◄─────────────────────────────────────── message ──────┤
```

## Security Considerations

- JWT token authentication
- HTTPS/WSS for production
- Input validation on backend
- File type validation for uploads
- Rate limiting on API endpoints
- Secure WebRTC (DTLS/SRTP)

## Environment Configuration

**Backend (.env file):**

```
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

**Flutter (.env or config file):**

```
API_BASE_URL=http://localhost:3000
SOCKET_URL=http://localhost:3000
STUN_SERVER_1=stun:stun.l.google.com:19302
STUN_SERVER_2=stun:stun1.l.google.com:19302
TURN_SERVER=turn:your-turn-server.com:3478
TURN_USERNAME=username
TURN_CREDENTIAL=credential
```

## WebRTC Configuration

**STUN/TURN Servers:**

- Free STUN: Google's public STUN servers (works for most cases)
- TURN Server needed for: Corporate networks, symmetric NATs
- Options:
                - Self-hosted: coturn (open source)
                - Cloud services: Twilio, Xirsys, Metered.ca
                - For testing: Google STUN servers are sufficient

**ICE Configuration Example:**

```dart
{
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {
      'urls': 'turn:your-turn-server.com:3478',
      'username': 'username',
      'credential': 'password'
    }
  ],
  'iceCandidatePoolSize': 10,
}
```

## Platform-Specific Setup

**Android (android/app/build.gradle):**

```gradle
minSdkVersion 21
targetSdkVersion 34
compileSdkVersion 34
```

**Android Permissions (android/app/src/main/AndroidManifest.xml):**

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

**iOS (ios/Podfile):**

```ruby
platform :ios, '12.0'
```

**iOS Permissions (ios/Runner/Info.plist):**

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice/video calls</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to send images</string>
```

## Development Setup Steps

### Backend Setup:

1. Install Node.js 18.x or 20.x LTS
2. Install MongoDB 6.0+
3. Clone/create project: `cd backend`
4. Install dependencies: `npm install`
5. Create `.env` file with configuration
6. Start MongoDB: `mongod` or use MongoDB Atlas (cloud)
7. Run server: `npm run dev` (with nodemon) or `npm start`

### Flutter Setup:

1. Install Flutter SDK 3.19.0+
2. Run `flutter doctor` to verify setup
3. Install platform-specific tools (Android Studio/Xcode)
4. Create project: `flutter create flutter_app`
5. Update `pubspec.yaml` with dependencies
6. Run `flutter pub get`
7. For iOS: `cd ios && pod install`
8. For Android: Update gradle files
9. Run app: `flutter run`

### Complete Backend package.json:

```json
{
  "name": "webrtc-chat-backend",
  "version": "1.0.0",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest --coverage"
  },
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.6.1",
    "mongoose": "^8.1.0",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "multer": "^1.4.5-lts.1",
    "qrcode": "^1.5.3",
    "cors": "^2.8.5",
    "dotenv": "^16.4.1",
    "express-validator": "^7.0.1",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5",
    "morgan": "^1.10.0",
    "compression": "^1.7.4",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.3",
    "jest": "^29.7.0",
    "supertest": "^6.3.4"
  }
}
```

### Complete Flutter pubspec.yaml:

```yaml
name: webrtc_chat_app
description: A cross-platform chat app with WebRTC
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # WebRTC & Communication
  flutter_webrtc: ^0.9.48
  socket_io_client: ^2.0.3+1
  
  # State Management
  provider: ^6.1.1
  
  # Network & API
  http: ^1.2.0
  dio: ^5.4.0
  
  # Permissions & Media
  permission_handler: ^11.3.0
  image_picker: ^1.0.7
  video_player: ^2.8.2
  cached_network_image: ^3.3.1
  
  # QR Code
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
  
  # Storage & Utils
  shared_preferences: ^2.2.2
  path_provider: ^2.1.2
  uuid: ^4.3.3
  intl: ^0.19.0
  
  # UI Components
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
flutter:
  uses-material-design: true
  assets:
  - assets/images/
```

### Database Schema:

**User Collection:**

```javascript
{
  _id: ObjectId,
  username: String (unique, indexed),
  password: String (hashed),
  displayName: String,
  avatar: String (URL),
  qrCode: String (base64 or URL),
  contacts: [ObjectId] (references to other users),
  createdAt: Date,
  lastSeen: Date,
  isOnline: Boolean
}
```

## Compatibility Matrix

| Package | Flutter SDK | Android | iOS | Web |

|---------|-------------|---------|-----|-----|

| flutter_webrtc | 3.0.0+ | ✓ | ✓ | ✓ |

| socket_io_client | 2.0.0+ | ✓ | ✓ | ✓ |

| permission_handler | 3.0.0+ | ✓ | ✓ | ✗ |

| image_picker | 3.0.0+ | ✓ | ✓ | ✓ |

| qr_code_scanner | 2.0.0+ | ✓ | ✓ | ✗ |

**Known Issues & Workarounds:**

- `flutter_webrtc` on iOS requires camera/mic permissions at runtime
- `qr_code_scanner` requires camera permission and doesn't work on Web
- WebRTC data channels may have message size limits (16KB default, configurable)
- Background call notifications require platform-specific implementations (Firebase Cloud Messaging)

## Testing Strategy

**Backend:**

- Jest for unit/integration tests
- Supertest for API endpoint testing
- Socket.io-client for signaling tests

**Flutter:**

- Unit tests: Services and business logic
- Widget tests: UI components
- Integration tests: Full WebRTC flow
- Manual testing: Real devices for calls (Android/iOS)

**Test Coverage Goals:**

- Backend: 80%+ coverage
- Flutter: 70%+ coverage for core services
- Manual: All call scenarios (1-to-1, reconnection, network switching)

## Additional Considerations

**Error Handling:**

- Network connectivity issues (offline/online detection)
- WebRTC connection failures (timeouts, ICE failures)
- Media permission denials
- File upload size/type validation
- Token expiration and refresh
- Socket disconnection/reconnection

**Performance Optimization:**

- Image compression before upload
- Video thumbnail generation
- Lazy loading for chat history
- Connection pooling for database
- Redis caching (optional, for scaling)
- CDN for media files (production)

**Deployment:**

**Backend:**

- Docker containerization
- Deploy to: AWS EC2, DigitalOcean, Heroku, or Render
- MongoDB Atlas for production database
- Configure HTTPS with Let's Encrypt
- Set up monitoring (PM2, New Relic, or Datadog)

**Flutter:**

- Build APK/AAB: `flutter build apk --release`
- Build iOS: `flutter build ios --release`
- Deploy to Google Play Store
- Deploy to Apple App Store
- Configure app signing

**Production Checklist:**

- Use production TURN servers
- Enable HTTPS/WSS
- Set secure JWT secrets
- Configure rate limiting
- Set up error logging (Sentry)
- Enable crash reporting (Firebase Crashlytics)
- Configure CDN for media
- Set up database backups
- Configure analytics (optional)
- Add privacy policy and terms of service

## Implementation Roadmap

**Phase 1: Foundation (Week 1-2)**

1. Set up backend with Express, Socket.io, MongoDB
2. Implement authentication (register/login)
3. Set up Flutter project structure
4. Implement theme and glassmorphic components
5. Create basic navigation

**Phase 2: Core Features (Week 3-4)**

6. Implement WebRTC service in Flutter
7. Set up signaling server logic
8. Build chat UI with message bubbles
9. Implement P2P messaging via data channels
10. Add contact management (search, add)

**Phase 3: Media & Calls (Week 5-6)**

11. Implement image/video picker and upload
12. Add media viewing in chat
13. Build call UI (incoming/active call screens)
14. Implement voice call functionality
15. Implement video call functionality

**Phase 4: Polish & Advanced (Week 7-8)**

16. Add QR code generation and scanning
17. Implement responsive layouts for tablets
18. Add call notifications (foreground)
19. Optimize media handling and compression
20. Add error handling and retry logic
21. Implement connection state indicators
22. Add user online/offline status

**Phase 5: Testing & Deployment (Week 9-10)**

23. Write unit and integration tests
24. Manual testing on multiple devices
25. Fix bugs and performance issues
26. Set up production infrastructure
27. Deploy backend to cloud
28. Build and release mobile apps