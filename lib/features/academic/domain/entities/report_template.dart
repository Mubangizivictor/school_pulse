import 'package:equatable/equatable.dart';

/// School-configurable report card template. Layout/colour/section choices
/// only - the visual drag-and-drop designer (Phase 4) extends this with a
/// positioned block list; this base shape is enough to render a sane
/// default template in the meantime.
class ReportTemplate extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String logoPosition; // 'left', 'center', 'right'
  final String photoPosition; // 'left', 'right', 'none'
  final String tableLayout; // 'traditional', 'competency'
  final List<String> enabledSections; // e.g., ['attendance', 'behaviour', 'comments']
  final String colorTheme;
  final String? backgroundWatermarkUrl;
  final bool showRanking;
  final bool showSubjectPosition;
  final String headerText;
  final String footerText;
  final bool isDefault;

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
    this.isDefault = false,
  });

  ReportTemplate copyWith({
    String? name,
    String? logoPosition,
    String? photoPosition,
    String? tableLayout,
    List<String>? enabledSections,
    String? colorTheme,
    String? backgroundWatermarkUrl,
    bool? showRanking,
    bool? showSubjectPosition,
    String? headerText,
    String? footerText,
    bool? isDefault,
  }) {
    return ReportTemplate(
      id: id,
      schoolId: schoolId,
      name: name ?? this.name,
      logoPosition: logoPosition ?? this.logoPosition,
      photoPosition: photoPosition ?? this.photoPosition,
      tableLayout: tableLayout ?? this.tableLayout,
      enabledSections: enabledSections ?? this.enabledSections,
      colorTheme: colorTheme ?? this.colorTheme,
      backgroundWatermarkUrl: backgroundWatermarkUrl ?? this.backgroundWatermarkUrl,
      showRanking: showRanking ?? this.showRanking,
      showSubjectPosition: showSubjectPosition ?? this.showSubjectPosition,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      isDefault: isDefault ?? this.isDefault,
    );
  }

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
        isDefault,
      ];
}
