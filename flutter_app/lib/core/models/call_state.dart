enum CallType { voice, video }
enum CallStatus { none, ringing, connecting, connected, ended, rejected, failed }

class CallState {
  final String? callId;
  final String? peerId;
  final String? peerName;
  final String? peerAvatar;
  final CallType? callType;
  final CallStatus status;
  final bool isIncoming;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerOn;
  final DateTime? startTime;
  final Duration? duration;

  CallState({
    this.callId,
    this.peerId,
    this.peerName,
    this.peerAvatar,
    this.callType,
    this.status = CallStatus.none,
    this.isIncoming = false,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isSpeakerOn = false,
    this.startTime,
    this.duration,
  });

  bool get isActive => status == CallStatus.connected;
  bool get isRinging => status == CallStatus.ringing;
  bool get isConnecting => status == CallStatus.connecting;
  bool get hasEnded => status == CallStatus.ended || 
                       status == CallStatus.rejected || 
                       status == CallStatus.failed;

  CallState copyWith({
    String? callId,
    String? peerId,
    String? peerName,
    String? peerAvatar,
    CallType? callType,
    CallStatus? status,
    bool? isIncoming,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isSpeakerOn,
    DateTime? startTime,
    Duration? duration,
  }) {
    return CallState(
      callId: callId ?? this.callId,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      isIncoming: isIncoming ?? this.isIncoming,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }

  factory CallState.idle() {
    return CallState(
      status: CallStatus.none,
    );
  }

  factory CallState.fromJson(Map<String, dynamic> json) {
    return CallState(
      callId: json['callId'],
      peerId: json['peerId'],
      peerName: json['peerName'],
      peerAvatar: json['peerAvatar'],
      callType: json['callType'] != null 
          ? CallType.values.firstWhere((e) => e.toString() == 'CallType.${json['callType']}')
          : null,
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == 'CallStatus.${json['status']}',
        orElse: () => CallStatus.none,
      ),
      isIncoming: json['isIncoming'] ?? false,
      isMuted: json['isMuted'] ?? false,
      isVideoEnabled: json['isVideoEnabled'] ?? true,
      isSpeakerOn: json['isSpeakerOn'] ?? false,
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'peerId': peerId,
      'peerName': peerName,
      'peerAvatar': peerAvatar,
      'callType': callType?.toString().split('.').last,
      'status': status.toString().split('.').last,
      'isIncoming': isIncoming,
      'isMuted': isMuted,
      'isVideoEnabled': isVideoEnabled,
      'isSpeakerOn': isSpeakerOn,
      'startTime': startTime?.toIso8601String(),
    };
  }
}
