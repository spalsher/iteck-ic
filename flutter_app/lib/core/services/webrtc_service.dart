import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import 'dart:convert';
import '../models/call_state.dart';
import 'socket_service.dart';

class WebRTCService {
  final SocketService _socketService;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCDataChannel? _dataChannel;
  dynamic _pendingOffer; // Store offer if received before user accepts
  
  final _remoteStreamController = StreamController<MediaStream?>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<MediaStream?> get remoteStream => _remoteStreamController.stream;
  Stream<CallState> get callState => _callStateController.stream;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  
  MediaStream? get localStream => _localStream;
  CallState _currentCallState = CallState.idle();

  // ICE servers configuration
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'iceCandidatePoolSize': 10,
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  WebRTCService(this._socketService) {
    _setupSocketListeners();
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    _socketService.on('call-request', _handleCallRequest);
    _socketService.on('call-accept', _handleCallAccept);
    _socketService.on('call-reject', _handleCallReject);
    _socketService.on('call-end', _handleCallEnd);
    _socketService.on('offer', _handleOffer);
    _socketService.on('answer', _handleAnswer);
    _socketService.on('ice-candidate', _handleIceCandidate);
  }

  // Initialize media (audio/video)
  Future<void> initializeMedia({bool video = true, bool audio = true}) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio,
        'video': video ? {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        } : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      print('✅ Local media initialized');
    } catch (e) {
      print('Error initializing media: $e');
      rethrow;
    }
  }

  // Create peer connection
  Future<void> _createPeerConnection() async {
    try {
      // Modern flutter_webrtc API - merged configuration
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      };
      
      _peerConnection = await createPeerConnection(configuration);

      // Add local stream tracks
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      // Handle remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream);
          print('✅ Remote stream received');
        }
      };

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (_currentCallState.peerId != null) {
          _socketService.sendIceCandidate(
            _currentCallState.peerId!,
            candidate.toMap(),
          );
        }
      };

      // Handle connection state changes
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        print('Connection state: $state');
        
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _updateCallState(_currentCallState.copyWith(
            status: CallStatus.connected,
            startTime: DateTime.now(),
          ));
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
                   state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          endCall();
        }
      };

      // Create data channel for messaging
      _dataChannel = await _peerConnection!.createDataChannel(
        'chat',
        RTCDataChannelInit()..maxRetransmits = 30,
      );
      
      _setupDataChannel(_dataChannel!);

      print('✅ Peer connection created');
    } catch (e) {
      print('Error creating peer connection: $e');
      rethrow;
    }
  }

  // Setup data channel
  void _setupDataChannel(RTCDataChannel channel) {
    channel.onMessage = (RTCDataChannelMessage message) {
      final data = jsonDecode(message.text);
      _messageController.add(data);
    };

    channel.onDataChannelState = (RTCDataChannelState state) {
      print('Data channel state: $state');
    };
  }

  // Send message via data channel
  void sendMessage(String message, String receiverId) {
    if (_dataChannel != null && _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      final data = {
        'type': 'text',
        'content': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'from': 'me',
        'to': receiverId,
      };
      
      _dataChannel!.send(RTCDataChannelMessage(jsonEncode(data)));
    } else {
      print('⚠️ Data channel not open, using signaling fallback');
      _socketService.sendMessage(to: receiverId, message: message);
    }
  }

  // Make call
  Future<void> makeCall({
    required String peerId,
    required String peerName,
    required CallType callType,
    String? peerAvatar,
  }) async {
    try {
      print('📞 Making call to $peerName ($peerId)');
      
      _updateCallState(CallState(
        peerId: peerId,
        peerName: peerName,
        peerAvatar: peerAvatar,
        callType: callType,
        status: CallStatus.connecting,
        isIncoming: false,
      ));

      // Initialize media
      print('🎥 Initializing media...');
      await initializeMedia(
        video: callType == CallType.video,
        audio: true,
      );

      // Create peer connection
      print('🔗 Creating peer connection...');
      await _createPeerConnection();

      // Send call request via signaling - DO NOT send offer yet!
      print('📡 Sending call request...');
      _socketService.sendCallRequest(
        to: peerId,
        callType: callType == CallType.video ? 'video' : 'voice',
        callerInfo: {
          'displayName': peerName,
          'avatar': peerAvatar ?? '',
        },
      );

      // Update to ringing status - wait for receiver to accept
      _updateCallState(_currentCallState.copyWith(status: CallStatus.ringing));
      print('✅ Call request sent, waiting for receiver to accept...');
      
      // Note: Offer will be created and sent when we receive 'call-accept' event
    } catch (e) {
      print('❌ Error making call: $e');
      _updateCallState(_currentCallState.copyWith(status: CallStatus.failed));
      await cleanup();
      rethrow;
    }
  }

  // Answer call
  Future<void> answerCall() async {
    try {
      if (_currentCallState.peerId == null) {
        throw Exception('No incoming call to answer');
      }

      print('📞 Answering call from ${_currentCallState.peerName}');
      _updateCallState(_currentCallState.copyWith(status: CallStatus.connecting));

      // Initialize media
      print('🎥 Initializing media for answer...');
      await initializeMedia(
        video: _currentCallState.callType == CallType.video,
        audio: true,
      );

      // Create peer connection
      print('🔗 Creating peer connection for answer...');
      await _createPeerConnection();

      // Accept call via signaling
      print('📡 Sending call accept...');
      _socketService.acceptCall(_currentCallState.peerId!);
      
      // Process pending offer if we received it before accepting
      if (_pendingOffer != null) {
        print('📥 Processing pending offer...');
        await _processOffer(_pendingOffer);
        _pendingOffer = null;
      }
      
      print('✅ Call answered successfully');
    } catch (e) {
      print('❌ Error answering call: $e');
      await rejectCall();
      rethrow;
    }
  }

  // Reject call
  Future<void> rejectCall({String reason = 'User declined'}) async {
    if (_currentCallState.peerId != null) {
      _socketService.rejectCall(_currentCallState.peerId!, reason: reason);
    }
    
    _updateCallState(_currentCallState.copyWith(status: CallStatus.rejected));
    await cleanup();
  }

  // End call
  Future<void> endCall() async {
    if (_currentCallState.peerId != null) {
      _socketService.endCall(_currentCallState.peerId!);
    }
    
    _updateCallState(_currentCallState.copyWith(status: CallStatus.ended));
    await cleanup();
  }

  // Toggle mute
  void toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      
      _updateCallState(_currentCallState.copyWith(
        isMuted: !audioTrack.enabled,
      ));
    }
  }

  // Toggle video
  void toggleVideo() {
    if (_localStream != null && _currentCallState.callType == CallType.video) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
      
      _updateCallState(_currentCallState.copyWith(
        isVideoEnabled: videoTrack.enabled,
      ));
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  // Handle incoming call request
  void _handleCallRequest(dynamic data) {
    print('📞 Incoming call request from ${data['from']}');
    print('Caller info: ${data['callerInfo']}');
    
    final callType = data['callType'] == 'video' ? CallType.video : CallType.voice;
    final callerInfo = data['callerInfo'] ?? {};
    
    _updateCallState(CallState(
      peerId: data['from'],
      peerName: callerInfo['displayName'] ?? callerInfo['username'] ?? 'Unknown',
      peerAvatar: callerInfo['avatar'] ?? '',
      callType: callType,
      status: CallStatus.ringing,
      isIncoming: true,
    ));
    
    print('✅ Call state updated - incoming ${callType == CallType.video ? "video" : "voice"} call');
  }

  // Handle call accept - receiver accepted, now send offer
  void _handleCallAccept(dynamic data) async {
    try {
      print('✅ Receiver accepted call, creating offer...');
      
      _updateCallState(_currentCallState.copyWith(status: CallStatus.connecting));
      
      // Now create and send the WebRTC offer
      if (_peerConnection != null) {
        print('📤 Creating and sending offer...');
        final offer = await _peerConnection!.createOffer(_dcConstraints);
        await _peerConnection!.setLocalDescription(offer);
        
        _socketService.sendOffer(_currentCallState.peerId!, offer.toMap());
        print('✅ Offer sent to receiver');
      } else {
        print('❌ Error: No peer connection available');
        await endCall();
      }
    } catch (e) {
      print('❌ Error creating offer after accept: $e');
      await endCall();
    }
  }

  // Handle call reject
  void _handleCallReject(dynamic data) {
    print('Call rejected: ${data['reason']}');
    _updateCallState(_currentCallState.copyWith(status: CallStatus.rejected));
    cleanup();
  }

  // Handle call end
  void _handleCallEnd(dynamic data) {
    print('Call ended by ${data['from']}');
    _updateCallState(_currentCallState.copyWith(status: CallStatus.ended));
    cleanup();
  }

  // Handle WebRTC offer
  void _handleOffer(dynamic data) async {
    try {
      print('📥 Received WebRTC offer from ${data['from']}');
      
      // CRITICAL: Only process offer if user has accepted (not in ringing state)
      // or if this is an outgoing call
      if (_currentCallState.isIncoming && _currentCallState.status == CallStatus.ringing) {
        print('⚠️ Offer received but user has not accepted yet - storing for later');
        _pendingOffer = data;
        return;
      }
      
      await _processOffer(data);
    } catch (e) {
      print('❌ Error handling offer: $e');
      await endCall();
    }
  }
  
  // Process the WebRTC offer
  Future<void> _processOffer(dynamic data) async {
    try {
      // Only create peer connection if we don't have one yet (for incoming calls after accept)
      if (_peerConnection == null) {
        print('Creating peer connection for incoming call...');
        await _createPeerConnection();
      }
      
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      
      print('Setting remote description...');
      await _peerConnection!.setRemoteDescription(offer);
      
      // Create and send answer
      print('Creating answer...');
      final answer = await _peerConnection!.createAnswer(_dcConstraints);
      await _peerConnection!.setLocalDescription(answer);
      
      print('Sending answer...');
      _socketService.sendAnswer(data['from'], answer.toMap());
      
      _updateCallState(_currentCallState.copyWith(status: CallStatus.connecting));
      
      print('✅ Offer processed successfully');
    } catch (e) {
      print('❌ Error processing offer: $e');
      rethrow;
    }
  }

  // Handle WebRTC answer
  void _handleAnswer(dynamic data) async {
    try {
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      
      await _peerConnection!.setRemoteDescription(answer);
      print('✅ Answer set successfully');
    } catch (e) {
      print('Error handling answer: $e');
      await endCall();
    }
  }

  // Handle ICE candidate
  void _handleIceCandidate(dynamic data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      
      await _peerConnection?.addCandidate(candidate);
    } catch (e) {
      print('Error handling ICE candidate: $e');
    }
  }

  // Update call state
  void _updateCallState(CallState newState) {
    _currentCallState = newState;
    _callStateController.add(_currentCallState);
  }

  // Cleanup resources
  Future<void> cleanup() async {
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();
    _localStream = null;

    _remoteStream?.dispose();
    _remoteStream = null;

    _dataChannel?.close();
    _dataChannel = null;

    await _peerConnection?.close();
    _peerConnection = null;
    
    _pendingOffer = null; // Clear pending offer

    _remoteStreamController.add(null);
  }

  // Dispose
  void dispose() {
    cleanup();
    _remoteStreamController.close();
    _callStateController.close();
    _messageController.close();
    
    _socketService.off('call-request', _handleCallRequest);
    _socketService.off('call-accept', _handleCallAccept);
    _socketService.off('call-reject', _handleCallReject);
    _socketService.off('call-end', _handleCallEnd);
    _socketService.off('offer', _handleOffer);
    _socketService.off('answer', _handleAnswer);
    _socketService.off('ice-candidate', _handleIceCandidate);
  }
}
