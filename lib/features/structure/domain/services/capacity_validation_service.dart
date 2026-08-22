import '../entities/structure_entities.dart';

/// Result of a capacity check: either allowed, or blocked with a
/// human-readable reason suitable for display directly to the user
/// (e.g. as a form field validator message).
class CapacityCheckResult {
  final bool isValid;
  final String? errorMessage;

  const CapacityCheckResult.valid() : isValid = true, errorMessage = null;

  const CapacityCheckResult.invalid(this.errorMessage) : isValid = false;
}

/// Pure, in-memory capacity/integrity rules for Classes & Streams.
///
/// Deliberately has no Firestore/repository dependency - it operates on
/// whatever [SchoolClass]/[ClassStream] lists the caller already has in
/// state (from [StructureState]), so it can be used identically from a
/// form field validator, the bloc, or a unit test.
class CapacityValidationService {
  const CapacityValidationService();

  /// Sum of capacities of active streams under [classId], optionally
  /// excluding one stream (used when editing an existing stream, so its
  /// own previous capacity isn't double-counted against itself).
  int activeStreamCapacity(
    List<ClassStream> streams,
    String classId, {
    String? excludingStreamId,
  }) {
    return streams
        .where(
          (s) =>
              s.classId == classId && s.isActive && s.id != excludingStreamId,
        )
        .fold(0, (sum, s) => sum + s.capacity);
  }

  /// Validates that saving [candidate] (new or edited) would not push the
  /// sum of active stream capacities under its parent class beyond that
  /// class's capacity. A class capacity of 0 means "no limit configured"
  /// and is not enforced (req #8: schools that don't use capacity limits
  /// aren't blocked).
  CapacityCheckResult validateStreamSave({
    required ClassStream candidate,
    required List<ClassStream> existingStreams,
    required List<SchoolClass> classes,
  }) {
    final parentClass = classes
        .where((c) => c.id == candidate.classId)
        .firstOrNull;
    if (parentClass == null) {
      return const CapacityCheckResult.invalid(
        'Selected class no longer exists.',
      );
    }
    if (parentClass.schoolId != candidate.schoolId) {
      return const CapacityCheckResult.invalid(
        'This stream\'s class belongs to a different school.',
      );
    }

    final duplicate = existingStreams.any(
      (s) =>
          s.id != candidate.id &&
          s.classId == candidate.classId &&
          s.isActive &&
          (s.name.trim().toLowerCase() == candidate.name.trim().toLowerCase() ||
              (candidate.code.trim().isNotEmpty &&
                  s.code.trim().toLowerCase() ==
                      candidate.code.trim().toLowerCase())),
    );
    if (duplicate) {
      return const CapacityCheckResult.invalid(
        'A stream with this name or code already exists in this class.',
      );
    }

    if (parentClass.capacity <= 0 || !candidate.isActive) {
      return const CapacityCheckResult.valid();
    }

    final otherActive = activeStreamCapacity(
      existingStreams,
      candidate.classId,
      excludingStreamId: candidate.id,
    );
    final total = otherActive + candidate.capacity;
    if (total > parentClass.capacity) {
      final available = parentClass.capacity - otherActive;
      return CapacityCheckResult.invalid(
        'Stream capacity exceeds available class capacity. '
        'Class capacity: ${parentClass.capacity}, '
        'already allocated: $otherActive, '
        'available: ${available < 0 ? 0 : available}.',
      );
    }
    return const CapacityCheckResult.valid();
  }

  /// Validates that changing a class's capacity to [newCapacity] would not
  /// drop it below the capacity already allocated to its active streams.
  CapacityCheckResult validateClassCapacityChange({
    required SchoolClass candidate,
    required int newCapacity,
    required List<ClassStream> streams,
  }) {
    if (newCapacity <= 0) return const CapacityCheckResult.valid();
    final allocated = activeStreamCapacity(streams, candidate.id);
    if (newCapacity < allocated) {
      return CapacityCheckResult.invalid(
        'Class capacity cannot be reduced below $allocated, the capacity '
        'already allocated to its active streams. Reduce or deactivate '
        'streams first.',
      );
    }
    return const CapacityCheckResult.valid();
  }

  /// Enrollment-vs-capacity check, used where actual headcounts (not just
  /// configured capacities) are available - e.g. after fetching student
  /// counts per class/stream.
  CapacityCheckResult validateEnrollment({
    required int capacity,
    required int currentEnrollment,
    required int additionalStudents,
    required String label,
  }) {
    if (capacity <= 0) return const CapacityCheckResult.valid();
    final total = currentEnrollment + additionalStudents;
    if (total > capacity) {
      return CapacityCheckResult.invalid(
        '$label enrollment would exceed capacity. '
        'Capacity: $capacity, currently enrolled: $currentEnrollment, '
        'attempting to add: $additionalStudents.',
      );
    }
    return const CapacityCheckResult.valid();
  }

  /// Reconciles a class's declared student total against the sum of its
  /// streams' enrolled totals - only meaningful once the class actually
  /// has streams (req #17).
  CapacityCheckResult validateClassStreamReconciliation({
    required int classEnrolledTotal,
    required int streamsEnrolledTotal,
    required bool classHasStreams,
  }) {
    if (!classHasStreams) return const CapacityCheckResult.valid();
    if (classEnrolledTotal != streamsEnrolledTotal) {
      return CapacityCheckResult.invalid(
        'Class enrollment ($classEnrolledTotal) does not match the sum of '
        'its streams\' enrollment ($streamsEnrolledTotal).',
      );
    }
    return const CapacityCheckResult.valid();
  }
}
