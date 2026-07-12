import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'mock_models.dart';

class MockData {
  static final students = [
    const Student(
      id: 's1',
      name: 'Mugisha Samuel',
      className: 'Primary 4',
      studentId: 'KHA/2023/001',
    ),
    const Student(
      id: 's2',
      name: 'Nakamya Sarah',
      className: 'Primary 2',
      studentId: 'KHA/2023/045',
    ),
    const Student(
      id: 's3',
      name: 'Okello John',
      className: 'Primary 6',
      studentId: 'KHA/2022/112',
    ),
    const Student(
      id: 's4',
      name: 'Babirye Joy',
      className: 'Primary 4',
      studentId: 'KHA/2023/002',
    ),
  ];

  static final parents = [
    const Parent(
      id: 'p1',
      name: 'Mr. Kato Joseph',
      studentIds: ['s1', 's4'], // Two children
      phoneNumber: '0772000001',
      accessCode: 'PARENT-123',
    ),
    const Parent(
      id: 'p2',
      name: 'Mrs. Namukasa Mary',
      studentIds: ['s2'],
      phoneNumber: '0772000002',
      accessCode: 'PARENT-456',
    ),
  ];

  static final alerts = [
    Alert(
      id: 'a1',
      title: 'Absence Alert',
      message: 'Mugisha Samuel was marked absent today.',
      severity: Severity.error,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Alert(
      id: 'a2',
      title: 'Fee Reminder',
      message: 'Tuition balance of UGX 250,000 for Nakamya Sarah is due soon.',
      severity: Severity.warning,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final academicRecords = [
    const AcademicRecord(
      studentId: 's1',
      subject: 'Mathematics',
      score: 85,
      grade: 'D1',
      term: 'Term 2',
      year: '2023',
      trend: 5,
      teacherRemark: 'Excellent performance. Keep it up.',
    ),
    const AcademicRecord(
      studentId: 's1',
      subject: 'English',
      score: 78,
      grade: 'D2',
      term: 'Term 2',
      year: '2023',
      trend: -2,
      teacherRemark: 'Good progress, but needs more practice in composition.',
    ),
    const AcademicRecord(
      studentId: 's1',
      subject: 'Science',
      score: 92,
      grade: 'D1',
      term: 'Term 2',
      year: '2023',
      trend: 3,
      teacherRemark: 'Outstanding understanding of scientific concepts.',
    ),
    const AcademicRecord(
      studentId: 's1',
      subject: 'Social Studies',
      score: 74,
      grade: 'C3',
      term: 'Term 2',
      year: '2023',
      trend: 0,
      teacherRemark: 'Satisfactory work. Focus on history section.',
    ),
    const AcademicRecord(
      studentId: 's4',
      subject: 'Mathematics',
      score: 95,
      grade: 'D1',
      term: 'Term 2',
      year: '2023',
      trend: 2,
      teacherRemark: 'Brilliant child. Always participates.',
    ),
    const AcademicRecord(
      studentId: 's4',
      subject: 'English',
      score: 88,
      grade: 'D1',
      term: 'Term 2',
      year: '2023',
      trend: 1,
      teacherRemark: 'Excellent reading skills.',
    ),
  ];

  static final attendanceRecords = [
    AttendanceRecord(
      studentId: 's1',
      date: DateTime.now(),
      status: StudentStatus.present,
    ),
    AttendanceRecord(
      studentId: 's4',
      date: DateTime.now(),
      status: StudentStatus.present,
    ),
    AttendanceRecord(
      studentId: 's1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: StudentStatus.absent,
      note: 'Family emergency',
    ),
    AttendanceRecord(
      studentId: 's4',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: StudentStatus.present,
    ),
    AttendanceRecord(
      studentId: 's1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: StudentStatus.late,
      note: 'Heavy rain',
    ),
    AttendanceRecord(
      studentId: 's4',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: StudentStatus.present,
    ),
    ...List.generate(20, (index) => AttendanceRecord(
      studentId: 's1',
      date: DateTime.now().subtract(Duration(days: index + 3)),
      status: StudentStatus.present,
    )),
    ...List.generate(20, (index) => AttendanceRecord(
      studentId: 's4',
      date: DateTime.now().subtract(Duration(days: index + 3)),
      status: StudentStatus.present,
    )),
  ];

  static final feeItems = [
    FeeItem(
      id: 'f1',
      studentId: 's1',
      category: 'Tuition',
      amount: 450000,
      status: FeeStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    FeeItem(
      id: 'f1_s4',
      studentId: 's4',
      category: 'Tuition',
      amount: 450000,
      status: FeeStatus.paid,
      dueDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    FeeItem(
      id: 'f2',
      studentId: 's1',
      category: 'Uniform',
      amount: 80000,
      status: FeeStatus.paid,
      dueDate: DateTime.now().subtract(const Duration(days: 45)),
    ),
    FeeItem(
      id: 'f3',
      studentId: 's1',
      category: 'Transport',
      amount: 150000,
      status: FeeStatus.due,
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    FeeItem(
      id: 'f3_s4',
      studentId: 's4',
      category: 'Club Membership',
      amount: 50000,
      status: FeeStatus.due,
      dueDate: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

  static final paymentRecords = [
    PaymentRecord(
      id: 'pay1',
      studentId: 's1',
      amount: 80000,
      date: DateTime.now().subtract(const Duration(days: 44)),
      method: 'MTN MoMo',
      reference: 'TXN123456789',
    ),
    PaymentRecord(
      id: 'pay1_s4',
      studentId: 's4',
      amount: 450000,
      date: DateTime.now().subtract(const Duration(days: 40)),
      method: 'MTN MoMo',
      reference: 'TXN444555666',
    ),
    PaymentRecord(
      id: 'pay2',
      studentId: 's1',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      method: 'Airtel Money',
      reference: 'TXN987654321',
    ),
  ];

  static final healthVisits = [
    HealthVisit(
      id: 'hv1',
      studentId: 's1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      reason: 'Slight fever',
      treatment: 'Rest and Paracetamol',
      medication: 'Paracetamol 500mg',
    ),
    HealthVisit(
      id: 'hv2',
      studentId: 's1',
      date: DateTime.now().subtract(const Duration(days: 15)),
      reason: 'Scraped knee during play',
      treatment: 'Cleaned and bandaged',
      medication: 'None',
    ),
  ];

  static final libraryBooks = [
    LibraryBook(
      id: 'lb1',
      studentId: 's1',
      title: 'The River Between',
      author: 'Ngugi wa Thiong\'o',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      isReturned: false,
    ),
    LibraryBook(
      id: 'lb2',
      studentId: 's1',
      title: 'Abyssinian Chronicles',
      author: 'Moses Isegawa',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isReturned: false,
    ),
  ];

  static final disciplineIncidents = [
    DisciplineIncident(
      id: 'di1',
      studentId: 's1',
      date: DateTime.now().subtract(const Duration(days: 20)),
      description: 'Talking during exam',
      severity: Severity.warning,
      resolution: 'Verbal warning and extra homework',
      counselingNotes: 'Student apologized and promised to focus.',
    ),
  ];

  static final transportInfo = [
    const TransportInfo(
      studentId: 's1',
      routeName: 'Entebbe Road Route',
      stopName: 'Lubowa Stage',
      status: 'On Route',
    ),
  ];

  static final chatThreads = [
    ChatThread(
      id: 't1',
      participantName: 'Mr. Okot (Class Teacher)',
      lastMessage: 'Please remember to bring the science project tomorrow.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatThread(
      id: 't2',
      participantName: 'School Announcements',
      lastMessage: 'End of Term holidays start on 15th December.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      isAnnouncement: true,
    ),
  ];

  static final chatMessages = [
    ChatMessage(
      id: 'm1',
      threadId: 't1',
      senderId: 'teacher1',
      text: 'Good afternoon. How is Samuel doing with his homework?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isMe: false,
    ),
    ChatMessage(
      id: 'm2',
      threadId: 't1',
      senderId: 'p1',
      text: 'He is doing well, almost finished with the math part.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isMe: true,
    ),
    ChatMessage(
      id: 'm3',
      threadId: 't1',
      senderId: 'teacher1',
      text: 'Great. Please remember to bring the science project tomorrow.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isMe: false,
    ),
  ];
}
