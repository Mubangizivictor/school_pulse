import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

import '../../domain/services/academic_calendar_service.dart';

/// Adapts the Structure module's calendar to what the Subject Teacher panel
/// needs. The panel never imports Structure directly, so a change to how the
/// school configures its calendar lands here and nowhere else.
class AcademicCalendarServiceImpl implements AcademicCalendarService {
  final StructureRepository structureRepository;

  /// The calendar changes at most a handful of times a year, but the panel
  /// asks for it on every scoped query. Caching it for the session avoids a
  /// Structure round trip per tab switch.
  AcademicPeriod? _cached;
  DateTime? _cachedAt;

  static const _cacheTtl = Duration(minutes: 15);

  AcademicCalendarServiceImpl({required this.structureRepository});

  @override
  Future<AcademicPeriod> getCurrentPeriod() async {
    final cached = _cached;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return cached;
    }

    final years = await structureRepository.watchAcademicYears().first;
    final year = _currentYear(years);
    if (year == null) return const AcademicPeriod(academicYearId: '');

    final terms = await structureRepository.watchAcademicTerms().first;
    final term = _currentTerm(terms, year.id);

    final period = AcademicPeriod(
      academicYearId: year.id,
      academicYearName: year.name,
      termId: term?.id ?? '',
      termName: term?.name ?? '',
    );
    _cached = period;
    _cachedAt = DateTime.now();
    return period;
  }

  @override
  Future<AcademicPeriod> getPeriodForDate(DateTime date) async {
    final years = await structureRepository.watchAcademicYears().first;
    final year = years
            .where((y) =>
                !y.isArchived &&
                !date.isBefore(y.startDate) &&
                !date.isAfter(y.endDate))
            .firstOrNull ??
        _currentYear(years);
    if (year == null) return const AcademicPeriod(academicYearId: '');

    final terms = await structureRepository.watchAcademicTerms().first;
    final term = terms
        .where((t) =>
            t.academicYearId == year.id &&
            !date.isBefore(t.startDate) &&
            !date.isAfter(t.endDate))
        .firstOrNull;

    return AcademicPeriod(
      academicYearId: year.id,
      academicYearName: year.name,
      termId: term?.id ?? '',
      termName: term?.name ?? '',
    );
  }

  /// The admin's `isCurrent` flag wins. If nobody has set it, fall back to
  /// the year whose date range contains today rather than showing nothing.
  AcademicYear? _currentYear(List<AcademicYear> years) {
    final flagged = years.where((y) => y.isCurrent && !y.isArchived).firstOrNull;
    if (flagged != null) return flagged;

    final now = DateTime.now();
    return years
        .where((y) =>
            !y.isArchived && !now.isBefore(y.startDate) && !now.isAfter(y.endDate))
        .firstOrNull;
  }

  AcademicTerm? _currentTerm(List<AcademicTerm> terms, String yearId) {
    final inYear = terms.where((t) => t.academicYearId == yearId).toList();
    final flagged = inYear.where((t) => t.isCurrent).firstOrNull;
    if (flagged != null) return flagged;

    final now = DateTime.now();
    return inYear
        .where((t) => !now.isBefore(t.startDate) && !now.isAfter(t.endDate))
        .firstOrNull;
  }

  /// Drops the session cache. Called when the admin edits the calendar and on
  /// logout, so a new session never inherits the previous school's period.
  void invalidate() {
    _cached = null;
    _cachedAt = null;
  }
}
