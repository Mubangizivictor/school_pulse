enum BiometricDeviceType { usb, bluetooth, otg, face, nfc }

class BiometricDevice {
  final String id;
  final String name;
  final String location;
  final BiometricDeviceType type;
  final bool isActive;
  final DateTime? lastSeen;
  final String? serialNumber;

  BiometricDevice({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.isActive = true,
    this.lastSeen,
    this.serialNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type.name,
      'isActive': isActive,
      'lastSeen': lastSeen?.toIso8601String(),
      'serialNumber': serialNumber,
    };
  }

  factory BiometricDevice.fromMap(Map<String, dynamic> map) {
    return BiometricDevice(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      type: BiometricDeviceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BiometricDeviceType.usb,
      ),
      isActive: map['isActive'] ?? true,
      lastSeen: map['lastSeen'] != null
          ? DateTime.parse(map['lastSeen'])
          : null,
      serialNumber: map['serialNumber'],
    );
  }
}
