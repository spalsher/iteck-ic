import 'package:flutter/material.dart';
import '../models/call_state.dart';
import 'webrtc_service.dart';

class CallManager {
  final WebRTCService _webrtcService;
  final GlobalKey<NavigatorState> navigatorKey;
  
  CallManager(this._webrtcService, this.navigatorKey) {
    _setupCallListeners();
  }

  void _setupCallListeners() {
    _webrtcService.callState.listen((callState) {
      print('CallManager: Call state changed - ${callState.status}, isIncoming: ${callState.isIncoming}');
      
      // Handle incoming call
      if (callState.isIncoming && callState.status == CallStatus.ringing) {
        print('CallManager: Showing incoming call screen for ${callState.peerName}');
        navigatorKey.currentState?.pushNamed('/incoming-call', arguments: callState);
      }
      
      // Handle call end
      if (callState.hasEnded) {
        print('CallManager: Call ended, popping screens');
        // Pop any call-related screens
        final currentRoute = ModalRoute.of(navigatorKey.currentContext!);
        if (currentRoute?.settings.name == '/active-call' || 
            currentRoute?.settings.name == '/incoming-call') {
          navigatorKey.currentState?.pop();
        }
      }
    });
  }
  
  void dispose() {
    // Cleanup if needed
  }
}
