import '../../domain/entities/report_template.dart';

class ReportTemplateModel extends ReportTemplate {
  const ReportTemplateModel({
    required super.id,
    required super.schoolId,
    required super.name,
    super.logoPosition,
    super.photoPosition,
    super.tableLayout,
    super.enabledSections,
    super.colorTheme,
    super.backgroundWatermarkUrl,
    super.showRanking,
    super.showSubjectPosition,
    super.headerText,
    super.footerText,
  });

  factory ReportTemplateModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportTemplateModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      logoPosition: map['logoPosition'] ?? 'center',
      photoPosition: map['photoPosition'] ?? 'right',
      tableLayout: map['tableLayout'] ?? 'traditional',
      enabledSections: List<String>.from(map['enabledSections'] ?? ['attendance', 'behaviour', 'comments']),
      colorTheme: map['colorTheme'] ?? 'blue',
      backgroundWatermarkUrl: map['backgroundWatermarkUrl'],
      showRanking: map['showRanking'] ?? false,
      showSubjectPosition: map['showSubjectPosition'] ?? false,
      headerText: map['headerText'] ?? '',
      footerText: map['footerText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'logoPosition': logoPosition,
      'photoPosition': photoPosition,
      'tableLayout': tableLayout,
      'enabledSections': enabledSections,
      'colorTheme': colorTheme,
      'backgroundWatermarkUrl': backgroundWatermarkUrl,
      'showRanking': showRanking,
      'showSubjectPosition': showSubjectPosition,
      'headerText': headerText,
      'footerText': footerText,
    };
  }
}
