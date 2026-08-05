enum BiometricEventType {
  enrollment,
  verificationSuccess,
  verificationFailed,
  deviceRegistered,
  deviceRemoved,
  templateUpdated,
}

class BiometricAuditLog {
  final String id;
  final String schoolId;
  final String? personId; // Student or Staff ID
  final String? personName;
  final String? personType; // 'student' or 'staff'
  final String deviceId;
  final String? operatorId;
  final BiometricEventType eventType;
  final DateTime timestamp;
  final String? result;
  final String? failureReason;
  final String? location;

  BiometricAuditLog({
    required this.id,
    required this.schoolId,
    this.personId,
    this.personName,
    this.personType,
    required this.deviceId,
    this.operatorId,
    required this.eventType,
    required this.timestamp,
    this.result,
    this.failureReason,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schoolId': schoolId,
      'personId': personId,
      'personName': personName,
      'personType': personType,
      'deviceId': deviceId,
      'operatorId': operatorId,
      'eventType': eventType.name,
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'failureReason': failureReason,
      'location': location,
    };
  }

  factory BiometricAuditLog.fromMap(Map<String, dynamic> map) {
    return BiometricAuditLog(
      id: map['id'] ?? '',
      schoolId: map['schoolId'] ?? '',
      personId: map['personId'],
      personName: map['personName'],
      personType: map['personType'],
      deviceId: map['deviceId'] ?? '',
      operatorId: map['operatorId'],
      eventType: BiometricEventType.values.firstWhere(
        (e) => e.name == map['eventType'],
        orElse: () => BiometricEventType.verificationFailed,
      ),
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      result: map['result'],
      failureReason: map['failureReason'],
      location: map['location'],
    );
  }
}
