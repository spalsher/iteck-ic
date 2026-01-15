import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/models/user.dart';
import '../../../core/models/message.dart';
import '../../../core/models/call_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/webrtc_service.dart';
import '../../../core/services/media_service.dart';
import '../../../core/config/environment.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final User contact;

  const ChatScreen({Key? key, required this.contact}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late SocketService _socketService;
  late WebRTCService _webrtcService;
  late MediaService _mediaService;
  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    _webrtcService = Provider.of<WebRTCService>(context, listen: false);
    _mediaService = Provider.of<MediaService>(context, listen: false);
    
    // Listen to incoming messages via socket
    _socketService.on('message', _handleIncomingMessage);
    
    // Load message history
    _loadMessages();
  }

  @override
  void dispose() {
    _socketService.off('message', _handleIncomingMessage);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoadingMessages = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Environment.baseUrl}/messages/conversation/${widget.contact.id}'),
        headers: authService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List)
            .map((json) => Message.fromJson({
              'id': json['_id'],
              'senderId': json['senderId']['_id'] ?? json['senderId'],
              'receiverId': json['receiverId']['_id'] ?? json['receiverId'],
              'content': json['content'],
              'type': json['type'],
              'timestamp': DateTime.parse(json['createdAt']).millisecondsSinceEpoch,
              'isSent': true,
              'isDelivered': json['isDelivered'] ?? false,
              'isRead': json['isRead'] ?? false,
              'mediaUrl': json['mediaUrl'],
              'thumbnailUrl': json['thumbnailUrl'],
            }))
            .toList();
        
        setState(() {
          _messages.addAll(messages);
          _isLoadingMessages = false;
        });
        
        _scrollToBottom();
        
        // Mark messages as read
        await http.put(
          Uri.parse('${Environment.baseUrl}/messages/read/${widget.contact.id}'),
          headers: authService.getHeaders(),
        );
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoadingMessages = false);
    }
  }

  void _handleIncomingMessage(dynamic data) {
    if (data['from'] == widget.contact.id) {
      final message = Message(
        id: data['id'] ?? const Uuid().v4(),
        senderId: data['from'],
        receiverId: data['to'] ?? 'me',
        content: data['content'] ?? data['message'] ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.toString() == 'MessageType.${data['type']}',
          orElse: () => MessageType.text,
        ),
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
        isSent: true,
        isDelivered: data['isDelivered'] ?? true,
        mediaUrl: data['mediaUrl'],
        thumbnailUrl: data['thumbnailUrl'],
      );
      
      setState(() {
        _messages.add(message);
      });
      
      _scrollToBottom();
      
      // Mark as read
      final authService = Provider.of<AuthService>(context, listen: false);
      http.put(
        Uri.parse('${Environment.baseUrl}/messages/read/${widget.contact.id}'),
        headers: authService.getHeaders(),
      );
    }
  }

  void _handleSendMessage(String text) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tempId = const Uuid().v4();
    final message = Message(
      id: tempId,
      senderId: authService.currentUser!.id,
      receiverId: widget.contact.id,
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isSent: true,
    );

    setState(() {
      _messages.add(message);
    });

    // Send via Socket.io (persists to database)
    _socketService.sendMessage(
      to: widget.contact.id,
      message: text,
      timestamp: message.timestamp.millisecondsSinceEpoch,
    );
    
    _scrollToBottom();
  }

  Future<void> _handleAttachMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryCyan),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _mediaService.pickImage();
                if (file != null) {
                  // Upload and send
                  try {
                    final result = await _mediaService.uploadMedia(file);
                    // Create and send image message
                  } catch (e) {
                    // Handle error
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryCyan),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _mediaService.takePhoto();
                if (file != null) {
                  // Upload and send
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primaryCyan),
              title: const Text('Video'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _mediaService.pickVideo();
                if (file != null) {
                  // Upload and send
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVoiceCall() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCyan),
        ),
      );

      print('Initiating voice call to ${widget.contact.displayName} (${widget.contact.id})');
      
      await _webrtcService.makeCall(
        peerId: widget.contact.id,
        peerName: widget.contact.displayName,
        callType: CallType.voice,
        peerAvatar: widget.contact.avatar.isNotEmpty ? widget.contact.avatar : null,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await Navigator.of(context).pushNamed('/active-call');
      }
    } catch (e) {
      print('Error initiating voice call: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Failed to initiate call: $e');
      }
    }
  }

  Future<void> _handleVideoCall() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCyan),
        ),
      );

      print('Initiating video call to ${widget.contact.displayName} (${widget.contact.id})');
      
      await _webrtcService.makeCall(
        peerId: widget.contact.id,
        peerName: widget.contact.displayName,
        callType: CallType.video,
        peerAvatar: widget.contact.avatar.isNotEmpty ? widget.contact.avatar : null,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await Navigator.of(context).pushNamed('/active-call');
      }
    } catch (e) {
      print('Error initiating video call: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Failed to initiate call: $e');
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryCyan,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.white,
              child: widget.contact.avatar.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        widget.contact.avatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      widget.contact.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.contact.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.contact.isOnline 
                          ? AppColors.lightCyan
                          : AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _handleVoiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _handleVideoCall,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryCyan.withOpacity(0.1),
              AppColors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _isLoadingMessages
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryCyan,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet\nStart the conversation!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: Responsive.fontSize(context, 16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(Responsive.spacing(context)),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == authService.currentUser?.id;
                            return MessageBubble(
                              message: message,
                              isMe: isMe,
                            );
                          },
                        ),
            ),
            
            // Input area
            ChatInput(
              onSendMessage: _handleSendMessage,
              onAttachMedia: _handleAttachMedia,
              onVoiceCall: _handleVoiceCall,
              onVideoCall: _handleVideoCall,
            ),
          ],
        ),
      ),
    );
  }
}
