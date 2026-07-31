import 'dart:convert';

/// ------------------------------------------------------------
/// SessionModel
/// ------------------------------------------------------------
/// Stores the authenticated user session.
/// ------------------------------------------------------------
class SessionModel {
  final String sessionId;
  final int userId;
  final String accessToken;
  final String refreshToken;
  final DateTime loginTime;
  final DateTime expiryTime;
  final DateTime lastActivity;
  final String deviceName;
  final String ipAddress;
  final bool isActive;

  const SessionModel({
    required this.sessionId,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.loginTime,
    required this.expiryTime,
    required this.lastActivity,
    required this.deviceName,
    required this.ipAddress,
    required this.isActive,
  });

  /// Empty Session
  factory SessionModel.empty() {
    final now = DateTime.now();

    return SessionModel(
      sessionId: '',
      userId: 0,
      accessToken: '',
      refreshToken: '',
      loginTime: now,
      expiryTime: now,
      lastActivity: now,
      deviceName: '',
      ipAddress: '',
      isActive: false,
    );
  }

  /// Copy With
  SessionModel copyWith({
    String? sessionId,
    int? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? loginTime,
    DateTime? expiryTime,
    DateTime? lastActivity,
    String? deviceName,
    String? ipAddress,
    bool? isActive,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      loginTime: loginTime ?? this.loginTime,
      expiryTime: expiryTime ?? this.expiryTime,
      lastActivity: lastActivity ?? this.lastActivity,
      deviceName: deviceName ?? this.deviceName,
      ipAddress: ipAddress ?? this.ipAddress,
      isActive: isActive ?? this.isActive,
    );
  }

  /// To Map
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'loginTime': loginTime.toIso8601String(),
      'expiryTime': expiryTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'isActive': isActive,
    };
  }

  /// From Map
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? 0,
      accessToken: map['accessToken'] ?? '',
      refreshToken: map['refreshToken'] ?? '',
      loginTime:
          DateTime.tryParse(map['loginTime'] ?? '') ?? DateTime.now(),
      expiryTime:
          DateTime.tryParse(map['expiryTime'] ?? '') ?? DateTime.now(),
      lastActivity:
          DateTime.tryParse(map['lastActivity'] ?? '') ?? DateTime.now(),
      deviceName: map['deviceName'] ?? '',
      ipAddress: map['ipAddress'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }

  /// To JSON
  String toJson() => jsonEncode(toMap());

  /// From JSON
  factory SessionModel.fromJson(String source) {
    return SessionModel.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  /// Check whether the session has expired.
  bool get isExpired => DateTime.now().isAfter(expiryTime);

  @override
  String toString() {
    return 'SessionModel(sessionId: $sessionId, userId: $userId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SessionModel &&
            sessionId == other.sessionId &&
            userId == other.userId &&
            accessToken == other.accessToken &&
            refreshToken == other.refreshToken &&
            loginTime == other.loginTime &&
            expiryTime == other.expiryTime &&
            lastActivity == other.lastActivity &&
            deviceName == other.deviceName &&
            ipAddress == other.ipAddress &&
            isActive == other.isActive;
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        userId,
        accessToken,
        refreshToken,
        loginTime,
        expiryTime,
        lastActivity,
        deviceName,
        ipAddress,
        isActive,
      );
}
