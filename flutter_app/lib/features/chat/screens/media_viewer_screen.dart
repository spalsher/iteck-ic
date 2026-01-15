import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

class MediaViewerScreen extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;

  const MediaViewerScreen({
    Key? key,
    required this.mediaUrl,
    this.isVideo = false,
  }) : super(key: key);

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
    );
    await _videoController!.initialize();
    setState(() {});
    _videoController!.play();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download media
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share media
            },
          ),
        ],
      ),
      body: Center(
        child: widget.isVideo
            ? _buildVideoPlayer()
            : _buildImageViewer(),
      ),
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.network(
        widget.mediaUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 64,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryCyan,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryCyan,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 80,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.primaryCyan,
              backgroundColor: AppColors.darkGray,
              bufferedColor: AppColors.lightGray,
            ),
          ),
        ),
      ],
    );
  }
}
