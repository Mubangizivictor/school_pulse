import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';

/// Loads Structure data for [institutionId] only if [StructureBloc] (a
/// single app-wide instance, already populated at sign-in - see
/// `main.dart`) has nothing yet. Re-dispatching `LoadStructureData`
/// unconditionally resets the bloc to an empty state and re-subscribes from
/// scratch (see `StructureBloc._onLoad`), which would wipe data every other
/// screen sharing the same bloc instance already has - this was the cause
/// of a stuck-forever loading spinner on Exam Factory's series/question/
/// paper screens when Structure was already loaded by the time they mounted.
void ensureStructureLoaded(BuildContext context, String institutionId) {
  final bloc = context.read<StructureBloc>();
  if (bloc.state.classes.isEmpty && bloc.state.subjects.isEmpty) {
    bloc.add(LoadStructureData(institutionId));
  }
}
