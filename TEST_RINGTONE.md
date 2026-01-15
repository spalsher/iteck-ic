# Ringtone Testing Instructions

## Current Status

The app is running successfully. The ringtone should play on the **RECEIVER's** device when an incoming call arrives.

## To Test the Ringtone:

### Setup:
- **Device A (Caller):** The device that initiates the call
- **Device B (Receiver):** The device that should hear the ringtone

### Test Steps:

1. **On Device B (Receiver):**
   - Open the app
   - Make sure device volume is UP (not silent/vibrate)
   - Watch the Flutter logs

2. **On Device A (Caller):**
   - Navigate to a contact
   - Tap the call button

3. **On Device B (Receiver):**
   - You should see the incoming call screen
   - You should hear a polyphonic ringtone (looping)
   - Watch for these logs in the terminal:
     ```
     🔔 Starting ringtone...
     🎵 Loading asset: sounds/ringtone.mp3
     🎵 Player state: PlayerState.playing
     ✅ Ringtone started successfully
     ```

4. **Tap Accept or Decline:**
   - Ringtone should stop
   - Log: `🔕 Stopping ringtone...`

## If No Ringtone is Heard:

### Check the Logs on Device B:

Look for:
- ✅ "Starting ringtone..." - Ringtone service called
- ❌ "Error playing ringtone" - Something failed
- ❌ No log at all - Incoming call screen didn't mount

### Quick Fix: Check Device Volume

```bash
# On Device B, ensure media volume is up
adb shell media volume --show
adb shell media volume --set 15  # Max volume
```

## Debug Command:

To see live logs from Device B while receiving a call:

```bash
# Terminal for Device B logs
adb -s neo7U250205123 logcat -s flutter:V | grep -E "Ringtone|🔔|🎵|audioplayers"
```

## Expected Flow:

```
📱 Device A calls Device B
    ↓
📲 Device B receives call-request
    ↓
🖥️ IncomingCallScreen mounts
    ↓
🔊 initState() calls _ringtoneService.playRingtone()
    ↓
🎵 Audioplayers starts playing ringtone.mp3
    ↓
🔁 Ringtone loops until user responds
    ↓
👆 User taps Accept/Decline
    ↓
🔇 stopRingtone() called
    ↓
✅ Call proceeds or dismisses
```

## Logs to Watch For:

**On Receiver (Device B):**
```
I/flutter: 📞 Incoming call request from...
I/flutter: ✅ Call state updated - incoming voice call
I/flutter: CallManager: Call state changed - CallStatus.ringing, isIncoming: true
I/flutter: 🔔 Starting ringtone...
I/flutter: 🎵 Loading asset: sounds/ringtone.mp3
I/flutter: 🎵 Player state: PlayerState.playing
I/flutter: ✅ Ringtone started successfully
```

**After Accept:**
```
I/flutter: 🔕 Stopping ringtone...
I/flutter: ✅ Ringtone stopped
I/flutter: 📞 Answering call from...
```

## Test Again:

Please make another test call and check the **receiver's device** for:
1. Does the incoming call screen appear?
2. Do you see ringtone logs in the console?
3. Can you hear any audio?
4. Is the device volume turned up?

Let me know what you observe!
