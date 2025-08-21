import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/cv_data.dart';

/// Service for exporting a professional CV as PDF with modern design
class CVExportService {
  const CVExportService._();

  /// Generate PDF document for CV (used by both export and preview)
  static Future<pw.Document> generatePDF(CVData cvData) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    final mediumFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Medium.ttf'));

    // Load profile image
    final profileImage = await _tryLoadProfileImage(cvData.personalInfo.profileImagePath);

    // Define colors
    const sidebarColor = PdfColor.fromInt(0xFF2C3E50); // Dark blue-gray
    const accentColor = PdfColor.fromInt(0xFF34495E); // Darker shade for headings
    const textDark = PdfColor.fromInt(0xFF2C3E50);
    const white70 = PdfColor.fromInt(0xB3FFFFFF); // 70% opacity white
    const white30 = PdfColor.fromInt(0x4DFFFFFF); // 30% opacity white

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          pw.Container(
            height: PdfPageFormat.a4.height,
            child: pw.Row(
              children: [
                // Left sidebar
                pw.Container(
                  width: 200,
                  height: PdfPageFormat.a4.height,
                  color: sidebarColor,
                  padding: const pw.EdgeInsets.all(20),
                  child: _buildSidebar(cvData, regularFont, boldFont, mediumFont, profileImage, white70, white30),
                ),
                // Right content area
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child: _buildMainContent(cvData, regularFont, boldFont, mediumFont, textDark, accentColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Generate and download a professional CV PDF
  static Future<void> exportToPDF(CVData cvData, [String? fileName]) async {
    final pdf = await generatePDF(cvData);

    // Save PDF
    await Printing.layoutPdf(
      name: fileName ?? 'cv_${cvData.personalInfo.lastName.toLowerCase()}',
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Build left sidebar content
  static pw.Widget _buildSidebar(
    CVData cvData,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font mediumFont,
    pw.ImageProvider? profileImage,
    PdfColor white70,
    PdfColor white30,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Profile photo
        if (profileImage != null)
          pw.Center(
            child: pw.Container(
              width: 120,
              height: 120,
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: PdfColors.white, width: 3),
              ),
              child: pw.ClipOval(child: pw.Image(profileImage, fit: pw.BoxFit.cover)),
            ),
          ),

        // Personal section
        _sidebarSection('Personal', boldFont),
        pw.SizedBox(height: 15),

        _sidebarItem(
          'Address',
          '${cvData.personalInfo.city ?? ''}, ${cvData.personalInfo.country ?? ''}',
          regularFont,
          white70,
        ),
        _sidebarItem('Phone number', cvData.personalInfo.phone, regularFont, white70),
        _sidebarItem('Email', cvData.personalInfo.email, regularFont, white70),
        _sidebarItem(
          'Location',
          '${cvData.personalInfo.city ?? ''}, ${cvData.personalInfo.country ?? ''}',
          regularFont,
          white70,
        ),
        if (cvData.personalInfo.github != null)
          _sidebarItem('GitHub', cvData.personalInfo.github!, regularFont, white70),
        if (cvData.personalInfo.linkedIn != null)
          _sidebarItem('LinkedIn', cvData.personalInfo.linkedIn!, regularFont, white70),
        if (cvData.personalInfo.website != null)
          _sidebarItem('Website', cvData.personalInfo.website!, regularFont, white70),

        pw.SizedBox(height: 25),

        // Languages section
        if (cvData.languages.isNotEmpty) ...[
          _sidebarSection('Languages', boldFont),
          pw.SizedBox(height: 10),
          ...cvData.languages.map((lang) => _sidebarLanguageItem(lang, regularFont)),
        ],

        // Skills section
        if (cvData.skills.isNotEmpty) ...[
          pw.SizedBox(height: 25),
          _sidebarSection('Skills', boldFont),
          pw.SizedBox(height: 10),
          ...cvData.skills.map((skill) => _sidebarSkillItem(skill, regularFont)),
        ],
      ],
    );
  }

  /// Build right main content area
  static pw.Widget _buildMainContent(
    CVData cvData,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font mediumFont,
    PdfColor textDark,
    PdfColor accentColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Name header
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                cvData.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(font: boldFont, fontSize: 32, color: textDark, letterSpacing: 2),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 4),
                height: 3,
                width: double.infinity,
                color: accentColor,
              ),
            ],
          ),
        ),

        // Professional summary
        if (cvData.summary != null && cvData.summary!.isNotEmpty) ...[
          pw.Text(
            cvData.summary!,
            style: pw.TextStyle(font: regularFont, fontSize: 11, color: textDark, lineSpacing: 1.5),
          ),
          pw.SizedBox(height: 25),
        ],

        // Work experience
        if (cvData.workExperiences.isNotEmpty) ...[
          _mainSection('Work experience', boldFont, accentColor),
          pw.SizedBox(height: 15),
          ...cvData.workExperiences.map((exp) => _workExperienceItem(exp, regularFont, mediumFont, textDark)),
        ],

        // Education
        if (cvData.educations.isNotEmpty) ...[
          _mainSection('Education and Qualifications', boldFont, accentColor),
          pw.SizedBox(height: 15),
          ...cvData.educations.map((edu) => _educationItem(edu, regularFont, mediumFont, textDark)),
        ],
      ],
    );
  }

  /// Sidebar section title
  static pw.Widget _sidebarSection(String title, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.white, width: 1)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.white, letterSpacing: 0.5),
      ),
    );
  }

  /// Sidebar key-value item
  static pw.Widget _sidebarItem(String label, String value, pw.Font font, PdfColor labelColor) {
    if (value.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 9, color: labelColor),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  /// Sidebar language item
  static pw.Widget _sidebarLanguageItem(Language lang, pw.Font regularFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lang.name,
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.white),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            lang.level.displayName,
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  /// Sidebar skill item with level text
  static pw.Widget _sidebarSkillItem(Skill skill, pw.Font regularFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            skill.name,
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.white),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            skill.level.displayName,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              color: const PdfColor.fromInt(0xB3FFFFFF),
            ), // 70% opacity white
          ),
        ],
      ),
    );
  }

  /// Main content section title
  static pw.Widget _mainSection(String title, pw.Font boldFont, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: color, letterSpacing: 0.5),
          ),
          pw.Container(margin: const pw.EdgeInsets.only(top: 5), height: 1.5, width: 50, color: color),
        ],
      ),
    );
  }

  /// Work experience item
  static pw.Widget _workExperienceItem(WorkExperience exp, pw.Font regularFont, pw.Font mediumFont, PdfColor textDark) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.jobTitle,
                style: pw.TextStyle(font: mediumFont, fontSize: 12, color: textDark),
              ),
              pw.Text(
                _formatDateRange(exp.startDate, exp.endDate, exp.isCurrentJob),
                style: pw.TextStyle(font: regularFont, fontSize: 10, color: textDark.shade(0.3)),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${exp.company}${exp.location != null ? ", ${exp.location}" : ""}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              color: textDark.shade(0.2),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          if (exp.description != null && exp.description!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              exp.description!,
              style: pw.TextStyle(font: regularFont, fontSize: 10, color: textDark, lineSpacing: 1.3),
            ),
          ],
        ],
      ),
    );
  }

  /// Education item
  static pw.Widget _educationItem(Education edu, pw.Font regularFont, pw.Font mediumFont, PdfColor textDark) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                edu.degree,
                style: pw.TextStyle(font: mediumFont, fontSize: 12, color: textDark),
              ),
              pw.Text(
                _formatDateRange(edu.startDate, edu.endDate, edu.isCurrentStudy),
                style: pw.TextStyle(font: regularFont, fontSize: 10, color: textDark.shade(0.3)),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${edu.institution}${edu.location != null ? ", ${edu.location}" : ""}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              color: textDark.shade(0.2),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Try to load a profile image from base64 data URL or asset path
  static Future<pw.ImageProvider?> _tryLoadProfileImage(String? profileImagePath) async {
    if (profileImagePath == null || profileImagePath.isEmpty) return null;
    try {
      // Case 1: data URL (with prefix)
      if (profileImagePath.startsWith('data:image/')) {
        final base64Data = profileImagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        return pw.MemoryImage(bytes);
      }

      // Case 2: plain base64 without prefix
      // Heuristic: contains only base64 chars and is long enough
      final base64Like = RegExp(r'^[A-Za-z0-9+/=]+$');
      if (profileImagePath.length > 100 && base64Like.hasMatch(profileImagePath)) {
        final bytes = base64Decode(profileImagePath);
        return pw.MemoryImage(bytes);
      }

      // Case 3: http/https or blob URL (web) – fetch via network
      if (profileImagePath.startsWith('http') || profileImagePath.startsWith('blob:')) {
        try {
          final img = await networkImage(profileImagePath);
          // networkImage already returns an ImageProvider compatible with pw.Image
          return img;
        } catch (_) {
          // fall through to next attempts
        }
      }

      // Case 4: treat as asset path bundled in app
      final asset = await rootBundle.load(profileImagePath);
      return pw.MemoryImage(asset.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  /// Utilities
  static String _formatMonthYear(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _formatDateRange(DateTime start, DateTime? end, bool isCurrent) {
    final startStr = _formatMonthYear(start);
    if (isCurrent) return '$startStr - Present';
    if (end != null) return '$startStr - ${_formatMonthYear(end)}';
    return startStr;
  }
}
