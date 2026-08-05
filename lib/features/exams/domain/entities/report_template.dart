import 'package:equatable/equatable.dart';

class ReportTemplate extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String logoPosition; // 'left', 'center', 'right'
  final String photoPosition;
  final String tableLayout; // 'traditional', 'competency'
  final List<String>
  enabledSections; // e.g., ['attendance', 'behaviour', 'comments']
  final String colorTheme;
  final String? backgroundWatermarkUrl;
  final bool showRanking;
  final bool showSubjectPosition;
  final String headerText;
  final String footerText;

  const ReportTemplate({
    required this.id,
    required this.schoolId,
    required this.name,
    this.logoPosition = 'center',
    this.photoPosition = 'right',
    this.tableLayout = 'traditional',
    this.enabledSections = const ['attendance', 'behaviour', 'comments'],
    this.colorTheme = 'blue',
    this.backgroundWatermarkUrl,
    this.showRanking = false,
    this.showSubjectPosition = false,
    this.headerText = '',
    this.footerText = '',
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    logoPosition,
    photoPosition,
    tableLayout,
    enabledSections,
    colorTheme,
    backgroundWatermarkUrl,
    showRanking,
    showSubjectPosition,
    headerText,
    footerText,
  ];
}
