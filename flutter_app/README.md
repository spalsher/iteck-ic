# WebRTC Chat App - Flutter

A cross-platform chat application with WebRTC for voice/video calls and P2P messaging, featuring a glassmorphic UI design with cyan/white theme.

## Features

- 📱 Cross-platform (Android, iOS, Web)
- 📞 Voice and video calls using WebRTC
- 💬 Real-time P2P text messaging via data channels
- 📸 Image and video sharing
- 🔍 Contact search and management
- 📲 QR code scanning for adding contacts
- 🎨 Modern glassmorphic UI design
- 📱 Responsive layouts for all screen sizes
- 🔐 JWT authentication
- 🔒 Secure WebRTC connections (DTLS/SRTP)

## Prerequisites

- Flutter SDK 3.19.0 or higher
- Dart 3.3.0 or higher
- Android Studio (for Android development)
- Xcode 15.0+ (for iOS development)
- Backend server running (see backend/README.md)

## Installation

1. Clone the repository
2. Install dependencies:

```bash
flutter pub get
```

3. For iOS, install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

4. Update the API URLs in the code:
   - `lib/core/services/auth_service.dart` - Update `baseUrl`
   - `lib/core/services/socket_service.dart` - Update `socketUrl`
   - `lib/core/services/media_service.dart` - Update `baseUrl`

## Running the App

### Development Mode

```bash
flutter run
```

### Build for Release

**Android:**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Configuration

### Android Setup

1. Update `android/app/build.gradle`:
```gradle
minSdkVersion 21
targetSdkVersion 34
```

2. Ensure permissions are set in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS Setup

1. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

2. Add permissions to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice/video calls</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to send images</string>
```

## Project Structure

```
lib/
├── core/
│   ├── models/           # Data models
│   ├── services/         # Core services (Auth, WebRTC, Socket, Media)
│   └── theme/           # Theme and styling
├── features/
│   ├── auth/            # Authentication screens
│   ├── chat/            # Chat screens and widgets
│   ├── calls/           # Call screens and widgets
│   └── contacts/        # Contact management
├── shared/
│   └── widgets/         # Reusable widgets
└── main.dart            # App entry point
```

## Key Dependencies

- `flutter_webrtc: ^0.9.48` - WebRTC implementation
- `socket_io_client: ^2.0.3+1` - Socket.io for signaling
- `provider: ^6.1.1` - State management
- `permission_handler: ^11.3.0` - Permission handling
- `image_picker: ^1.0.7` - Media selection
- `qr_flutter: ^4.1.0` - QR code generation
- `qr_code_scanner: ^1.0.1` - QR code scanning

## Usage

### Authentication

1. Launch the app
2. Register a new account or login with existing credentials
3. Grant necessary permissions when prompted

### Making Calls

1. Add contacts by searching for username or scanning QR code
2. Open a chat with a contact
3. Tap the phone icon for voice call or video icon for video call

### Sending Messages

1. Type your message in the chat input
2. Tap send icon or press enter
3. Attach media by tapping the attachment icon

### Adding Contacts

Three ways to add contacts:
1. Search by username
2. Scan QR code
3. Share your QR code for others to scan

## Troubleshooting

### WebRTC Connection Issues

- Ensure STUN/TURN servers are configured correctly
- Check network connectivity
- Verify firewall settings allow WebRTC connections

### Permission Errors

- Make sure all required permissions are granted in device settings
- Re-request permissions if denied

### Build Issues

- Run `flutter clean` and `flutter pub get`
- For iOS: `cd ios && pod install && cd ..`
- Update Flutter and dependencies to latest versions

## Performance Optimization

- Images are automatically compressed before upload
- Lazy loading for chat history
- Efficient state management with Provider
- WebRTC bandwidth optimization

## Security

- JWT token authentication
- Secure WebRTC connections (DTLS/SRTP)
- Input validation
- File type validation for uploads
- Token refresh mechanism

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT

## Support

For issues and questions, please create an issue in the repository.
