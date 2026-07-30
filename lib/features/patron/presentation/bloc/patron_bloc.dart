import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

class PatronBloc extends Bloc<PatronEvent, PatronState> {
  final PatronRepository repository;
  StreamSubscription? _dormitorySubscription;
  StreamSubscription? _studentSubscription;
  StreamSubscription? _attendanceSubscription;
  StreamSubscription? _welfareSubscription;
  StreamSubscription? _disciplineSubscription;
  StreamSubscription? _announcementSubscription;

  PatronBloc({required this.repository}) : super(PatronInitial()) {
    on<LoadPatronDashboard>(_onLoadDashboard);
    on<WatchDormitories>(_onWatchDormitories);
    on<WatchBoardingStudents>(_onWatchBoardingStudents);
    on<AddDormitoryEvent>(_onAddDormitory);
    on<UpdateDormitoryEvent>(_onUpdateDormitory);
    on<DeleteDormitoryEvent>(_onDeleteDormitory);
    on<AllocateStudentEvent>(_onAllocateStudent);
    on<SetRoomLeaderEvent>(_onSetRoomLeader);
    on<RecordAttendanceEvent>(_onRecordAttendance);
    on<BulkRecordAttendanceEvent>(_onBulkRecordAttendance);
    on<WatchAttendance>(_onWatchAttendance);
    on<LogWelfareRecordEvent>(_onLogWelfareRecord);
    on<WatchWelfareRecords>(_onWatchWelfareRecords);
    on<LogDisciplineIncidentEvent>(_onLogDisciplineIncident);
    on<UpdateDisciplineStatusEvent>(_onUpdateDisciplineStatus);
    on<WatchDisciplineIncidents>(_onWatchDisciplineIncidents);
    on<PostAnnouncementEvent>(_onPostAnnouncement);
    on<WatchAnnouncements>(_onWatchAnnouncements);
    on<_DormitoriesUpdated>(_onDormitoriesUpdated);
    on<_StudentsUpdated>(_onStudentsUpdated);
    on<_AttendanceUpdated>(_onAttendanceUpdated);
    on<_WelfareUpdated>(_onWelfareUpdated);
    on<_DisciplineUpdated>(_onDisciplineUpdated);
    on<_AnnouncementsUpdated>(_onAnnouncementsUpdated);
  }

  Future<void> _onLoadDashboard(
    LoadPatronDashboard event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());
    // For dashboard, we might want a combined state or just trigger multiple watchers
    // For now, let's just trigger individual watches if needed or a dedicated summary stream
  }

  void _onWatchDormitories(WatchDormitories event, Emitter<PatronState> emit) {
    _dormitorySubscription?.cancel();
    _dormitorySubscription = repository.getDormitories().listen(
      (dormitories) => add(_DormitoriesUpdated(dormitories)),
    );
  }

  void _onWatchBoardingStudents(
    WatchBoardingStudents event,
    Emitter<PatronState> emit,
  ) {
    _studentSubscription?.cancel();
    _studentSubscription = repository
        .getBoardingStudents(event.dormitoryId)
        .listen((students) => add(_StudentsUpdated(students)));
  }

  Future<void> _onAddDormitory(
    AddDormitoryEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.addDormitory(event.dormitory);
      emit(const PatronActionSuccess('Dormitory added successfully'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onUpdateDormitory(
    UpdateDormitoryEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.updateDormitory(event.dormitory);
      emit(const PatronActionSuccess('Dormitory updated successfully'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onDeleteDormitory(
    DeleteDormitoryEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.deleteDormitory(event.id);
      emit(const PatronActionSuccess('Dormitory deleted successfully'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onAllocateStudent(
    AllocateStudentEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.allocateStudentToDorm(
        event.studentId,
        event.dormitoryId,
        event.bedNumber,
      );
      emit(const PatronActionSuccess('Student allocated successfully'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onSetRoomLeader(
    SetRoomLeaderEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.setRoomLeader(event.dormitoryId, event.studentId);
      emit(const PatronActionSuccess('Room leader updated'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onRecordAttendance(
    RecordAttendanceEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.recordAttendance(event.attendance);
      emit(const PatronActionSuccess('Attendance recorded'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onBulkRecordAttendance(
    BulkRecordAttendanceEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.bulkRecordAttendance(event.records);
      emit(const PatronActionSuccess('Attendance records saved'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchAttendance(WatchAttendance event, Emitter<PatronState> emit) {
    _attendanceSubscription?.cancel();
    _attendanceSubscription = repository
        .getAttendance(event.date, event.dormitoryId, event.type)
        .listen((attendance) => add(_AttendanceUpdated(attendance)));
  }

  Future<void> _onLogWelfareRecord(
    LogWelfareRecordEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.logWelfareRecord(event.record);
      emit(const PatronActionSuccess('Welfare record saved'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchWelfareRecords(
    WatchWelfareRecords event,
    Emitter<PatronState> emit,
  ) {
    _welfareSubscription?.cancel();
    if (event.studentId != null) {
      _welfareSubscription = repository
          .getWelfareRecords(
            event.schoolId,
            event.studentId!,
            publicOnly: event.publicOnly,
          )
          .listen((records) => add(_WelfareUpdated(records)));
    } else {
      _welfareSubscription = repository
          .getAllWelfareRecords(event.schoolId, publicOnly: event.publicOnly)
          .listen((records) => add(_WelfareUpdated(records)));
    }
  }

  Future<void> _onLogDisciplineIncident(
    LogDisciplineIncidentEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.logDisciplineIncident(event.incident);
      emit(const PatronActionSuccess('Discipline incident logged'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onUpdateDisciplineStatus(
    UpdateDisciplineStatusEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.updateDisciplineStatus(
        event.incidentId,
        event.status,
        event.actionTaken,
      );
      emit(const PatronActionSuccess('Discipline status updated'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchDisciplineIncidents(
    WatchDisciplineIncidents event,
    Emitter<PatronState> emit,
  ) {
    _disciplineSubscription?.cancel();
    _disciplineSubscription = repository
        .getDisciplineIncidents(event.studentId)
        .listen((incidents) => add(_DisciplineUpdated(incidents)));
  }

  Future<void> _onPostAnnouncement(
    PostAnnouncementEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.postAnnouncement(event.announcement);
      emit(const PatronActionSuccess('Announcement posted'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchAnnouncements(
    WatchAnnouncements event,
    Emitter<PatronState> emit,
  ) {
    _announcementSubscription?.cancel();
    _announcementSubscription = repository.getAnnouncements().listen(
      (announcements) => add(_AnnouncementsUpdated(announcements)),
    );
  }

  // Internal helper events for stream updates
  void _onDormitoriesUpdated(
    _DormitoriesUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(DormitoriesLoaded(event.dormitories));
  }

  void _onStudentsUpdated(_StudentsUpdated event, Emitter<PatronState> emit) {
    emit(BoardingStudentsLoaded(event.students));
  }

  void _onAttendanceUpdated(
    _AttendanceUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(AttendanceLoaded(event.attendance));
  }

  void _onWelfareUpdated(_WelfareUpdated event, Emitter<PatronState> emit) {
    emit(WelfareRecordsLoaded(event.records));
  }

  void _onDisciplineUpdated(
    _DisciplineUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(DisciplineIncidentsLoaded(event.incidents));
  }

  void _onAnnouncementsUpdated(
    _AnnouncementsUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(AnnouncementsLoaded(event.announcements));
  }

  @override
  Future<void> close() {
    _dormitorySubscription?.cancel();
    _studentSubscription?.cancel();
    _attendanceSubscription?.cancel();
    _welfareSubscription?.cancel();
    _disciplineSubscription?.cancel();
    _announcementSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream listening
class _DormitoriesUpdated extends PatronEvent {
  final List<Dormitory> dormitories;
  const _DormitoriesUpdated(this.dormitories);
}

class _StudentsUpdated extends PatronEvent {
  final List<BoardingStudent> students;
  const _StudentsUpdated(this.students);
}

class _AttendanceUpdated extends PatronEvent {
  final List<BoardingAttendance> attendance;
  const _AttendanceUpdated(this.attendance);
}

class _WelfareUpdated extends PatronEvent {
  final List<WelfareRecord> records;
  const _WelfareUpdated(this.records);
}

class _DisciplineUpdated extends PatronEvent {
  final List<DisciplineIncident> incidents;
  const _DisciplineUpdated(this.incidents);
}

class _AnnouncementsUpdated extends PatronEvent {
  final List<BoardingAnnouncement> announcements;
  const _AnnouncementsUpdated(this.announcements);
}
