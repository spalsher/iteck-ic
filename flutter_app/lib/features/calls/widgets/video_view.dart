import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/app_colors.dart';

class VideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool mirror;
  final bool isLocal;

  const VideoView({
    Key? key,
    required this.renderer,
    this.mirror = false,
    this.isLocal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(isLocal ? 12 : 0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isLocal ? 12 : 0),
        child: Transform(
          alignment: Alignment.center,
          transform: mirror ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
          child: RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            mirror: false,
          ),
        ),
      ),
    );
  }
}
