import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../shared/widgets/glassmorphic_container.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onAttachMedia;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.onAttachMedia,
    required this.onVoiceCall,
    required this.onVideoCall,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Responsive.spacing(context)),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, multiplier: 0.75),
        vertical: Responsive.spacing(context, multiplier: 0.5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCyan.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Attach button
          IconButton(
            icon: Icon(Icons.attach_file, color: AppColors.darkCyan.withOpacity(0.7)),
            onPressed: widget.onAttachMedia,
            iconSize: 24,
          ),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: AppColors.darkCyan,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: AppColors.darkCyan.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          
          // Call buttons (when no text)
          if (!_hasText) ...[
            IconButton(
              icon: Icon(Icons.phone, color: AppColors.primaryCyan),
              onPressed: widget.onVoiceCall,
              iconSize: 24,
            ),
            IconButton(
              icon: Icon(Icons.videocam, color: AppColors.primaryCyan),
              onPressed: widget.onVideoCall,
              iconSize: 24,
            ),
          ],
          
          // Send button (when has text)
          if (_hasText)
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }
}
