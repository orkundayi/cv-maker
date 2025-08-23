import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/cv_data.dart';
import '../templates/cv_template.dart';
import '../templates/cv_template_registry.dart';

/// Service for exporting CV as PDF using template system
class CVExportService {
  const CVExportService._();

  // Initialize template registry on first use
  static bool _initialized = false;
  static void _ensureInitialized() {
    if (!_initialized) {
      CVTemplateRegistry().initialize();
      _initialized = true;
    }
  }

  /// Generate PDF document for CV using specified template
  /// If templateId is not provided, uses the default template
  static Future<pw.Document> generatePDF(CVData cvData, {String? templateId}) async {
    _ensureInitialized();

    // Get the template
    final registry = CVTemplateRegistry();
    CVTemplate? template;

    if (templateId != null) {
      template = registry.getTemplate(templateId);
    }

    // Fallback to default template if not found
    template ??= registry.getDefaultTemplate();

    // Generate PDF using the selected template
    return template.generatePDF(cvData);
  }

  /// Generate and download a professional CV PDF with template support
  static Future<void> exportToPDF(CVData cvData, {String? fileName, String? templateId}) async {
    final pdf = await generatePDF(cvData, templateId: templateId);

    // Save PDF
    await Printing.layoutPdf(
      name: fileName ?? 'cv_${cvData.personalInfo.lastName.toLowerCase()}',
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Get all available templates
  static List<CVTemplate> getAvailableTemplates() {
    _ensureInitialized();
    return CVTemplateRegistry().getAllTemplates();
  }

  /// Get a specific template by ID
  static CVTemplate? getTemplate(String templateId) {
    _ensureInitialized();
    return CVTemplateRegistry().getTemplate(templateId);
  }

  /// Check if a template exists
  static bool hasTemplate(String templateId) {
    _ensureInitialized();
    return CVTemplateRegistry().hasTemplate(templateId);
  }
}
