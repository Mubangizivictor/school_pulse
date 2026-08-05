import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

class PatronBloc extends Bloc<PatronEvent, PatronState> {
  final PatronRepository repository;
  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _dormitorySubscription;
  StreamSubscription? _studentSubscription;
  StreamSubscription? _unallocatedSubscription;
  StreamSubscription? _bedsSubscription;
  StreamSubscription? _transferHistorySubscription;
  StreamSubscription? _attendanceSubscription;
  StreamSubscription? _leaveSubscription;
  StreamSubscription? _welfareSubscription;
  StreamSubscription? _referralSubscription;
  StreamSubscription? _behaviourSubscription;
  StreamSubscription? _disciplineSubscription;
  StreamSubscription? _announcementSubscription;

  PatronBloc({required this.repository}) : super(PatronInitial()) {
    on<LoadPatronDashboard>(_onLoadDashboard);
    on<WatchDashboardOverview>(_onWatchDashboardOverview);
    on<WatchDormitories>(_onWatchDormitories);
    on<WatchBoardingStudents>(_onWatchBoardingStudents);
    on<WatchUnallocatedStudents>(_onWatchUnallocatedStudents);
    on<AddDormitoryEvent>(_onAddDormitory);
    on<UpdateDormitoryEvent>(_onUpdateDormitory);
    on<DeleteDormitoryEvent>(_onDeleteDormitory);
    on<SetDormLeadershipEvent>(_onSetDormLeadership);
    on<AllocateStudentEvent>(_onAllocateStudent);
    on<SetRoomLeaderEvent>(_onSetRoomLeader);
    on<WatchBeds>(_onWatchBeds);
    on<AddBedEvent>(_onAddBed);
    on<RemoveBedEvent>(_onRemoveBed);
    on<TransferStudentEvent>(_onTransferStudent);
    on<WatchTransferHistory>(_onWatchTransferHistory);
    on<RecordAttendanceEvent>(_onRecordAttendance);
    on<BulkRecordAttendanceEvent>(_onBulkRecordAttendance);
    on<WatchAttendance>(_onWatchAttendance);
    on<WatchLeaveRequests>(_onWatchLeaveRequests);
    on<RequestLeaveEvent>(_onRequestLeave);
    on<UpdateLeaveStatusEvent>(_onUpdateLeaveStatus);
    on<LogWelfareRecordEvent>(_onLogWelfareRecord);
    on<WatchWelfareRecords>(_onWatchWelfareRecords);
    on<WatchCounselingReferrals>(_onWatchCounselingReferrals);
    on<LogCounselingReferralEvent>(_onLogCounselingReferral);
    on<UpdateReferralStatusEvent>(_onUpdateReferralStatus);
    on<WatchBehaviourObservations>(_onWatchBehaviourObservations);
    on<LogBehaviourObservationEvent>(_onLogBehaviourObservation);
    on<LogDisciplineIncidentEvent>(_onLogDisciplineIncident);
    on<UpdateDisciplineStatusEvent>(_onUpdateDisciplineStatus);
    on<WatchDisciplineIncidents>(_onWatchDisciplineIncidents);
    on<PostAnnouncementEvent>(_onPostAnnouncement);
    on<WatchAnnouncements>(_onWatchAnnouncements);
    on<_DashboardOverviewUpdated>(_onDashboardOverviewUpdated);
    on<_DormitoriesUpdated>(_onDormitoriesUpdated);
    on<_StudentsUpdated>(_onStudentsUpdated);
    on<_UnallocatedUpdated>(_onUnallocatedUpdated);
    on<_BedsUpdated>(_onBedsUpdated);
    on<_TransferHistoryUpdated>(_onTransferHistoryUpdated);
    on<_AttendanceUpdated>(_onAttendanceUpdated);
    on<_LeaveUpdated>(_onLeaveUpdated);
    on<_WelfareUpdated>(_onWelfareUpdated);
    on<_ReferralsUpdated>(_onReferralsUpdated);
    on<_BehaviourUpdated>(_onBehaviourUpdated);
    on<_DisciplineUpdated>(_onDisciplineUpdated);
    on<_AnnouncementsUpdated>(_onAnnouncementsUpdated);
  }

  Future<void> _onLoadDashboard(
    LoadPatronDashboard event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());
  }

  void _onWatchDashboardOverview(
    WatchDashboardOverview event,
    Emitter<PatronState> emit,
  ) {
    _dashboardSubscription?.cancel();
    _dashboardSubscription = repository
        .watchDashboardOverview(event.schoolId)
        .listen((overview) => add(_DashboardOverviewUpdated(overview)));
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

  void _onWatchUnallocatedStudents(
    WatchUnallocatedStudents event,
    Emitter<PatronState> emit,
  ) {
    _unallocatedSubscription?.cancel();
    _unallocatedSubscription = repository.getUnallocatedStudents().listen(
      (students) => add(_UnallocatedUpdated(students)),
    );
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

  Future<void> _onSetDormLeadership(
    SetDormLeadershipEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.setDormLeadership(
        event.dormitoryId,
        roomLeaderId: event.roomLeaderId,
        dormPrefectId: event.dormPrefectId,
      );
      emit(const PatronActionSuccess('Dorm leadership updated'));
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

  void _onWatchBeds(WatchBeds event, Emitter<PatronState> emit) {
    _bedsSubscription?.cancel();
    _bedsSubscription = repository
        .getBeds(event.dormitoryId)
        .listen((beds) => add(_BedsUpdated(beds)));
  }

  Future<void> _onAddBed(AddBedEvent event, Emitter<PatronState> emit) async {
    try {
      await repository.addBed(event.dormitoryId, event.bedNumber);
      emit(const PatronActionSuccess('Bed added'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onRemoveBed(
    RemoveBedEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.removeBed(event.dormitoryId, event.bedId);
      emit(const PatronActionSuccess('Bed removed'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onTransferStudent(
    TransferStudentEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.transferStudent(
        studentId: event.studentId,
        toDormitoryId: event.toDormitoryId,
        toBedNumber: event.toBedNumber,
        transferredBy: event.transferredBy,
        reason: event.reason,
      );
      emit(const PatronActionSuccess('Student transferred'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchTransferHistory(
    WatchTransferHistory event,
    Emitter<PatronState> emit,
  ) {
    _transferHistorySubscription?.cancel();
    _transferHistorySubscription = repository
        .getTransferHistory(event.studentId)
        .listen((transfers) => add(_TransferHistoryUpdated(transfers)));
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
        .getAttendance(
          event.schoolId,
          event.date,
          event.dormitoryId,
          event.type,
        )
        .listen((attendance) => add(_AttendanceUpdated(attendance)));
  }

  void _onWatchLeaveRequests(
    WatchLeaveRequests event,
    Emitter<PatronState> emit,
  ) {
    _leaveSubscription?.cancel();
    _leaveSubscription = repository
        .getLeaveRequests(status: event.status)
        .listen((requests) => add(_LeaveUpdated(requests)));
  }

  Future<void> _onRequestLeave(
    RequestLeaveEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.requestLeave(event.request);
      emit(const PatronActionSuccess('Leave request submitted'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onUpdateLeaveStatus(
    UpdateLeaveStatusEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.updateLeaveStatus(
        event.requestId,
        event.status,
        approvedBy: event.approvedBy,
        actualReturnDate: event.actualReturnDate,
        notes: event.notes,
      );
      emit(const PatronActionSuccess('Leave request updated'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
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

  void _onWatchCounselingReferrals(
    WatchCounselingReferrals event,
    Emitter<PatronState> emit,
  ) {
    _referralSubscription?.cancel();
    _referralSubscription = repository
        .getCounselingReferrals(event.studentId)
        .listen((referrals) => add(_ReferralsUpdated(referrals)));
  }

  Future<void> _onLogCounselingReferral(
    LogCounselingReferralEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.logCounselingReferral(event.referral);
      emit(const PatronActionSuccess('Counseling referral logged'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  Future<void> _onUpdateReferralStatus(
    UpdateReferralStatusEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.updateReferralStatus(
        event.referralId,
        event.status,
        followUpNotes: event.followUpNotes,
      );
      emit(const PatronActionSuccess('Referral updated'));
    } catch (e) {
      emit(PatronError(e.toString()));
    }
  }

  void _onWatchBehaviourObservations(
    WatchBehaviourObservations event,
    Emitter<PatronState> emit,
  ) {
    _behaviourSubscription?.cancel();
    _behaviourSubscription = repository
        .getBehaviourObservations(event.studentId)
        .listen((observations) => add(_BehaviourUpdated(observations)));
  }

  Future<void> _onLogBehaviourObservation(
    LogBehaviourObservationEvent event,
    Emitter<PatronState> emit,
  ) async {
    try {
      await repository.logBehaviourObservation(event.observation);
      emit(const PatronActionSuccess('Behaviour observation logged'));
    } catch (e) {
      emit(PatronError(e.toString()));
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
  void _onDashboardOverviewUpdated(
    _DashboardOverviewUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(DashboardOverviewLoaded(event.overview));
  }

  void _onDormitoriesUpdated(
    _DormitoriesUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(DormitoriesLoaded(event.dormitories));
  }

  void _onStudentsUpdated(_StudentsUpdated event, Emitter<PatronState> emit) {
    emit(BoardingStudentsLoaded(event.students));
  }

  void _onUnallocatedUpdated(
    _UnallocatedUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(UnallocatedStudentsLoaded(event.students));
  }

  void _onBedsUpdated(_BedsUpdated event, Emitter<PatronState> emit) {
    emit(BedsLoaded(event.beds));
  }

  void _onTransferHistoryUpdated(
    _TransferHistoryUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(TransferHistoryLoaded(event.transfers));
  }

  void _onAttendanceUpdated(
    _AttendanceUpdated event,
    Emitter<PatronState> emit,
  ) {
    emit(AttendanceLoaded(event.attendance));
  }

  void _onLeaveUpdated(_LeaveUpdated event, Emitter<PatronState> emit) {
    emit(LeaveRequestsLoaded(event.requests));
  }

  void _onWelfareUpdated(_WelfareUpdated event, Emitter<PatronState> emit) {
    emit(WelfareRecordsLoaded(event.records));
  }

  void _onReferralsUpdated(_ReferralsUpdated event, Emitter<PatronState> emit) {
    emit(CounselingReferralsLoaded(event.referrals));
  }

  void _onBehaviourUpdated(_BehaviourUpdated event, Emitter<PatronState> emit) {
    emit(BehaviourObservationsLoaded(event.observations));
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
    _dashboardSubscription?.cancel();
    _dormitorySubscription?.cancel();
    _studentSubscription?.cancel();
    _unallocatedSubscription?.cancel();
    _bedsSubscription?.cancel();
    _transferHistorySubscription?.cancel();
    _attendanceSubscription?.cancel();
    _leaveSubscription?.cancel();
    _welfareSubscription?.cancel();
    _referralSubscription?.cancel();
    _behaviourSubscription?.cancel();
    _disciplineSubscription?.cancel();
    _announcementSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream listening
class _DashboardOverviewUpdated extends PatronEvent {
  final PatronDashboardOverview overview;
  const _DashboardOverviewUpdated(this.overview);
}

class _DormitoriesUpdated extends PatronEvent {
  final List<Dormitory> dormitories;
  const _DormitoriesUpdated(this.dormitories);
}

class _StudentsUpdated extends PatronEvent {
  final List<BoardingStudent> students;
  const _StudentsUpdated(this.students);
}

class _UnallocatedUpdated extends PatronEvent {
  final List<BoardingStudent> students;
  const _UnallocatedUpdated(this.students);
}

class _BedsUpdated extends PatronEvent {
  final List<Bed> beds;
  const _BedsUpdated(this.beds);
}

class _TransferHistoryUpdated extends PatronEvent {
  final List<BedTransfer> transfers;
  const _TransferHistoryUpdated(this.transfers);
}

class _AttendanceUpdated extends PatronEvent {
  final List<BoardingAttendance> attendance;
  const _AttendanceUpdated(this.attendance);
}

class _LeaveUpdated extends PatronEvent {
  final List<LeaveRequest> requests;
  const _LeaveUpdated(this.requests);
}

class _WelfareUpdated extends PatronEvent {
  final List<WelfareRecord> records;
  const _WelfareUpdated(this.records);
}

class _ReferralsUpdated extends PatronEvent {
  final List<CounselingReferral> referrals;
  const _ReferralsUpdated(this.referrals);
}

class _BehaviourUpdated extends PatronEvent {
  final List<BehaviourObservation> observations;
  const _BehaviourUpdated(this.observations);
}

class _DisciplineUpdated extends PatronEvent {
  final List<DisciplineIncident> incidents;
  const _DisciplineUpdated(this.incidents);
}

class _AnnouncementsUpdated extends PatronEvent {
  final List<BoardingAnnouncement> announcements;
  const _AnnouncementsUpdated(this.announcements);
}
