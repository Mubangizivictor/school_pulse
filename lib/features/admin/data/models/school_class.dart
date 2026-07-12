class SchoolClass {
  final String id;
  final String name;
  final int streamCount;
  final int studentCount;

  SchoolClass({
    required this.id,
    required this.name,
    required this.streamCount,
    required this.studentCount,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'streamCount': streamCount,
        'studentCount': studentCount,
      };

  factory SchoolClass.fromMap(Map<String, dynamic> map, String id) => SchoolClass(
        id: id,
        name: map['name'] ?? '',
        streamCount: map['streamCount'] ?? 0,
        studentCount: map['studentCount'] ?? 0,
      );
}

class Department {
  final String id;
  final String name;
  final String headName;
  final int memberCount;

  Department({
    required this.id,
    required this.name,
    required this.headName,
    required this.memberCount,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'headName': headName,
        'memberCount': memberCount,
      };

  factory Department.fromMap(Map<String, dynamic> map, String id) => Department(
        id: id,
        name: map['name'] ?? '',
        headName: map['headName'] ?? '',
        memberCount: map['memberCount'] ?? 0,
      );
}
