import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/models/call_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../core/services/webrtc_service.dart';
import '../widgets/video_view.dart';
import '../widgets/call_controls.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({Key? key}) : super(key: key);

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late WebRTCService _webrtcService;
  CallState _callState = CallState.idle();

  @override
  void initState() {
    super.initState();
    _webrtcService = Provider.of<WebRTCService>(context, listen: false);
    _initRenderers();
    
    // Listen to call state changes
    _webrtcService.callState.listen((state) {
      if (mounted) {
        setState(() {
          _callState = state;
        });
        
        // Handle call end
        if (state.hasEnded) {
          Navigator.of(context).pop();
        }
      }
    });
    
    // Listen to remote stream
    _webrtcService.remoteStream.listen((stream) {
      if (stream != null && mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    });
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      
      // Set local stream AFTER renderers are initialized
      if (mounted && _webrtcService.localStream != null) {
        setState(() {
          _localRenderer.srcObject = _webrtcService.localStream;
        });
      }
    } catch (e) {
      print('Error initializing renderers: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoCall = _callState.callType == CallType.video;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkGray,
              AppColors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Remote video (full screen)
              if (isVideoCall && _callState.isActive)
                Positioned.fill(
                  child: VideoView(
                    renderer: _remoteRenderer,
                    isLocal: false,
                  ),
                ),
              
              // Remote audio only (avatar)
              if (!isVideoCall || !_callState.isActive)
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassmorphicContainer(
                          borderRadius: 100,
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: _callState.peerAvatar != null && _callState.peerAvatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _callState.peerAvatar!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 80,
                                    color: AppColors.primaryCyan,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _callState.peerName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 28),
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getCallStatusText(),
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Local video (picture-in-picture)
              if (isVideoCall && _callState.isVideoEnabled)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Switch to full screen local video
                    },
                    child: SizedBox(
                      width: Responsive.isMobile(context) ? 120 : 200,
                      height: Responsive.isMobile(context) ? 160 : 266,
                      child: VideoView(
                        renderer: _localRenderer,
                        mirror: true,
                        isLocal: true,
                      ),
                    ),
                  ),
                ),
              
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GlassmorphicContainer(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  margin: EdgeInsets.all(Responsive.spacing(context)),
                  child: Row(
                    children: [
                      if (!isVideoCall || !_callState.isActive)
                        const Icon(Icons.phone, color: AppColors.white),
                      if (isVideoCall && _callState.isActive)
                        const Icon(Icons.videocam, color: AppColors.white),
                      const SizedBox(width: 12),
                      Text(
                        _callState.peerName ?? 'Unknown',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_callState.duration != null)
                        Text(
                          _formatDuration(_callState.duration!),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: CallControls(
                    isMuted: _callState.isMuted,
                    isVideoEnabled: _callState.isVideoEnabled,
                    isSpeakerOn: _callState.isSpeakerOn,
                    onToggleMute: () {
                      _webrtcService.toggleMute();
                    },
                    onToggleVideo: () {
                      _webrtcService.toggleVideo();
                    },
                    onToggleSpeaker: () {
                      // Toggle speaker
                    },
                    onSwitchCamera: () {
                      _webrtcService.switchCamera();
                    },
                    onEndCall: () {
                      _webrtcService.endCall();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCallStatusText() {
    switch (_callState.status) {
      case CallStatus.ringing:
        return 'Ringing...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      default:
        return '';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
