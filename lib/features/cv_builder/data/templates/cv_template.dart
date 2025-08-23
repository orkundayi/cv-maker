import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../domain/cv_data.dart';

/// Abstract base class for CV templates
abstract class CVTemplate {
  /// Template identifier
  String get id;

  /// Template display name
  String get name;

  /// Template description
  String get description;

  /// Template preview image path or icon
  String get previewImage;

  /// Generate PDF document using this template
  Future<pw.Document> generatePDF(CVData cvData);

  /// Get required fonts for this template
  Future<TemplateFonts> loadFonts();
}

/// Container for template fonts
class TemplateFonts {
  final pw.Font? regularFont;
  final pw.Font? boldFont;
  final pw.Font? mediumFont;
  final pw.Font? lightFont;
  final pw.Font? italicFont;

  TemplateFonts({this.regularFont, this.boldFont, this.mediumFont, this.lightFont, this.italicFont});
}

/// Template color scheme
class TemplateColors {
  final PdfColor primary;
  final PdfColor secondary;
  final PdfColor accent;
  final PdfColor text;
  final PdfColor textLight;
  final PdfColor background;

  const TemplateColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.textLight,
    required this.background,
  });
}
