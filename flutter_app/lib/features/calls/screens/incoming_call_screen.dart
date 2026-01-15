import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/call_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../core/services/webrtc_service.dart';
import '../../../core/services/ringtone_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallState callState;

  const IncomingCallScreen({Key? key, required this.callState}) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final RingtoneService _ringtoneService = RingtoneService();
  
  @override
  void initState() {
    super.initState();
    // Start playing ringtone
    _ringtoneService.playRingtone();
  }
  
  @override
  void dispose() {
    // Stop ringtone when screen is disposed
    _ringtoneService.stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webrtcService = Provider.of<WebRTCService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryCyan,
              AppColors.darkCyan,
              AppColors.lightCyan,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Caller avatar
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
                    child: widget.callState.peerAvatar != null && widget.callState.peerAvatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              widget.callState.peerAvatar!,
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
                
                const SizedBox(height: 40),
                
                // Caller name
                Text(
                  widget.callState.peerName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 32),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Call type
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.callState.callType == CallType.video
                            ? Icons.videocam
                            : Icons.phone,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Incoming ${widget.callState.callType == CallType.video ? 'Video' : 'Voice'} Call',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 18),
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Call actions
                Padding(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reject button
                      _buildCallButton(
                        icon: Icons.call_end,
                        color: AppColors.error,
                        label: 'Decline',
                        onPressed: () async {
                          // Stop ringtone when declining
                          _ringtoneService.stopRingtone();
                          await webrtcService.rejectCall();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      
                      // Accept button
                      _buildCallButton(
                        icon: Icons.call,
                        color: AppColors.success,
                        label: 'Accept',
                        onPressed: () async {
                          // Stop ringtone when accepting
                          _ringtoneService.stopRingtone();
                          
                          try {
                            print('Accepting incoming call...');
                            await webrtcService.answerCall();
                            if (context.mounted) {
                              print('Navigating to active call screen...');
                              Navigator.of(context).pushReplacementNamed('/active-call');
                            }
                          } catch (e) {
                            print('Error answering call: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to answer call: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GlassmorphicContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 40,
          color: color.withOpacity(0.3),
          child: InkWell(
            onTap: onPressed,
            child: Icon(
              icon,
              size: 40,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
