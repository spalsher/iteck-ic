# Ringtone Troubleshooting Guide

## Issue: Ringtone Not Playing

### Fixes Applied:

#### 1. **Improved RingtoneService** ✅
- Changed from single player instance to creating new instance each time
- Added comprehensive logging at every step
- Set `PlayerMode.mediaPlayer` for better Android compatibility
- Increased volume to 1.0 (100%)
- Added player state listeners for debugging
- Better error handling with stack traces

#### 2. **Asset Path Verification** ✅
- Confirmed `assets/sounds/ringtone.mp3` exists (33KB)
- Confirmed `pubspec.yaml` includes asset path
- Ran `flutter clean` and `flutter pub get` to rebuild

#### 3. **Audio Player Configuration** ✅
- Set proper release mode (loop)
- Set proper player mode (mediaPlayer)
- Added state change listeners for debugging

### Debug Logs to Monitor:

When an incoming call arrives, you should see these logs:

```
🔔 Starting ringtone...
🎵 Loading asset: sounds/ringtone.mp3
🎵 Player state: PlayerState.playing
✅ Ringtone started successfully
```

When accepting/declining:
```
🔕 Stopping ringtone...
✅ Ringtone stopped
```

### If Ringtone Still Doesn't Play:

#### Check 1: Verify Asset is Bundled
```bash
cd flutter_app
flutter clean
flutter pub get
flutter build apk --debug
# Check if asset is in the APK
unzip -l build/app/outputs/flutter-apk/app-debug.apk | grep ringtone
```

#### Check 2: Check Device Volume
- Ensure device media volume is turned up
- Not on silent/vibrate mode
- Check if other apps can play audio

#### Check 3: Check Permissions (Android)
The app already has these permissions in `AndroidManifest.xml`:
- `INTERNET`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`
- `ACCESS_NETWORK_STATE`

#### Check 4: Check Flutter Logs
```bash
# Watch for ringtone logs
flutter logs | grep -E "🔔|🎵|Ringtone|audioplayers"
```

#### Check 5: Alternative Audio Source
If asset still doesn't work, we can use a URL source as fallback:
```dart
await _player!.play(
  UrlSource('https://www.soundjay.com/phone/sounds/phone-calling-1.mp3'),
);
```

### Testing Steps:

1. **Install Updated App**
   ```bash
   cd flutter_app
   flutter run -d neo7U250205123
   ```

2. **Make a Test Call**
   - From Device A, call Device B
   - Watch Device B's screen for logs
   - Check terminal output for ringtone logs

3. **Check Audio Output**
   - Verify device volume is up
   - Try with headphones if available
   - Check if vibration works (backup feedback)

### Common Issues & Solutions:

| Issue | Solution |
|-------|----------|
| Asset not found | Run `flutter clean && flutter pub get` |
| No audio permission | Check AndroidManifest.xml |
| Volume too low | Set volume to 1.0 in code |
| Player not initialized | Create new player instance each time |
| Loop not working | Set `ReleaseMode.loop` before play |
| Wrong audio mode | Use `PlayerMode.mediaPlayer` |

### Alternative: Use Device Vibration

If audio still doesn't work, we can add vibration as feedback:

```dart
import 'package:vibration/vibration.dart';

// In incoming_call_screen.dart
void _startRingingFeedback() {
  _ringtoneService.playRingtone();
  // Also vibrate
  Vibration.vibrate(
    duration: 1000,
    amplitude: 128,
    pattern: [500, 1000, 500, 2000], // Vibrate pattern
  );
}
```

Add to pubspec.yaml:
```yaml
dependencies:
  vibration: ^1.8.4
```

### Current Status:

✅ RingtoneService updated with better logging
✅ Asset path verified
✅ Dependencies installed
✅ App rebuilding with fixes

**Next:** Test incoming call to see logs and hear ringtone!
