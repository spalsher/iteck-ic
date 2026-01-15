class User {
  final String id;
  final String username;
  final String displayName;
  final String avatar;
  final String qrCode;
  final List<String> contacts;
  final bool isOnline;
  final DateTime lastSeen;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar = '',
    this.qrCode = '',
    this.contacts = const [],
    this.isOnline = false,
    required this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatar: json['avatar'] ?? '',
      qrCode: json['qrCode'] ?? '',
      contacts: json['contacts'] != null 
          ? List<String>.from(json['contacts'].map((c) => c is String ? c : c['_id']))
          : [],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'qrCode': qrCode,
      'contacts': contacts,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? qrCode,
    List<String>? contacts,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      qrCode: qrCode ?? this.qrCode,
      contacts: contacts ?? this.contacts,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
