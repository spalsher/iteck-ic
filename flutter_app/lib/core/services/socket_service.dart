import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../config/environment.dart';

class SocketService {
  static final String socketUrl = Environment.socketUrl;
  
  IO.Socket? _socket;
  final Map<String, List<Function>> _eventHandlers = {};
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  // Connect to socket server
  Future<void> connect(String token) async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _isConnected = true;
      _notifyListeners('connect', null);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
      _notifyListeners('disconnect', null);
    });

    _socket!.onConnectError((data) {
      print('🔴 Socket connection error: $data');
      _notifyListeners('error', data);
    });

    _socket!.onError((data) {
      print('🔴 Socket error: $data');
      _notifyListeners('error', data);
    });

    _socket!.connect();
  }

  // Disconnect
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _eventHandlers.clear();
  }

  // Emit event
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    } else {
      print('⚠️ Socket not connected, cannot emit: $event');
    }
  }

  // Listen to event
  void on(String event, Function(dynamic) handler) {
    if (!_eventHandlers.containsKey(event)) {
      _eventHandlers[event] = [];
      
      // Register with socket
      _socket?.on(event, (data) {
        _notifyListeners(event, data);
      });
    }
    
    _eventHandlers[event]!.add(handler);
  }

  // Remove listener
  void off(String event, [Function? handler]) {
    if (handler != null && _eventHandlers.containsKey(event)) {
      _eventHandlers[event]!.remove(handler);
      
      if (_eventHandlers[event]!.isEmpty) {
        _eventHandlers.remove(event);
        _socket?.off(event);
      }
    } else {
      _eventHandlers.remove(event);
      _socket?.off(event);
    }
  }

  // Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_eventHandlers.containsKey(event)) {
      for (var handler in _eventHandlers[event]!) {
        handler(data);
      }
    }
  }

  // Signaling methods
  void sendCallRequest({
    required String to,
    required String callType,
    required Map<String, dynamic> callerInfo,
  }) {
    emit('call-request', {
      'to': to,
      'callType': callType,
      'callerInfo': callerInfo,
    });
  }

  void acceptCall(String to) {
    emit('call-accept', {'to': to});
  }

  void rejectCall(String to, {String reason = 'User declined'}) {
    emit('call-reject', {'to': to, 'reason': reason});
  }

  void endCall(String to) {
    emit('call-end', {'to': to});
  }

  void sendOffer(String to, Map<String, dynamic> offer) {
    emit('offer', {'to': to, 'offer': offer});
  }

  void sendAnswer(String to, Map<String, dynamic> answer) {
    emit('answer', {'to': to, 'answer': answer});
  }

  void sendIceCandidate(String to, Map<String, dynamic> candidate) {
    emit('ice-candidate', {'to': to, 'candidate': candidate});
  }

  void sendMessage({
    required String to,
    required String message,
    int? timestamp,
  }) {
    emit('message', {
      'to': to,
      'message': message,
      'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    });
  }

  void sendTyping(String to) {
    emit('typing', {'to': to});
  }

  void sendStopTyping(String to) {
    emit('stop-typing', {'to': to});
  }
}
