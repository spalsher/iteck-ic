import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glassmorphic_container.dart';

class CallControls extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerOn;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;

  const CallControls({
    Key? key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.isSpeakerOn,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onToggleSpeaker,
    required this.onSwitchCamera,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            isActive: !isMuted,
            onPressed: onToggleMute,
          ),
          
          // Video button
          _buildControlButton(
            icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            isActive: isVideoEnabled,
            onPressed: onToggleVideo,
          ),
          
          // Speaker button
          _buildControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            isActive: isSpeakerOn,
            onPressed: onToggleSpeaker,
          ),
          
          // Switch camera button
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            isActive: true,
            onPressed: onSwitchCamera,
          ),
          
          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            isActive: false,
            color: AppColors.error,
            onPressed: onEndCall,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 30,
      color: color?.withOpacity(0.3) ?? 
             (isActive 
                 ? AppColors.primaryCyan.withOpacity(0.3)
                 : AppColors.white.withOpacity(0.1)),
      child: InkWell(
        onTap: onPressed,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}
