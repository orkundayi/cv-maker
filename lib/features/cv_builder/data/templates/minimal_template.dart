import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'cv_template.dart';
import 'template_localizations.dart';
import '../../domain/cv_data.dart';

/// Minimal CV template with clean, simple design
class MinimalTemplate extends CVTemplate {
  @override
  String get id => 'minimal_clean';

  @override
  String get name => 'Minimal';

  @override
  String get description => 'Simple and clean CV design focusing on content';

  @override
  String get previewImage => 'assets/templates/minimal_clean_preview.png';

  // Template specific colors
  static const _colors = TemplateColors(
    primary: PdfColor.fromInt(0xFF000000), // Black
    secondary: PdfColor.fromInt(0xFF666666), // Gray
    accent: PdfColor.fromInt(0xFF0066CC), // Blue accent
    text: PdfColor.fromInt(0xFF333333), // Dark gray text
    textLight: PdfColor.fromInt(0xFF666666), // Light gray text
    background: PdfColor.fromInt(0xFFF5F5F5), // Light background
  );

  @override
  Future<TemplateFonts> loadFonts() async {
    return TemplateFonts(
      regularFont: pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      ),
      boldFont: pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      ),
      lightFont: pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Light.ttf'),
      ),
      mediumFont: pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Medium.ttf'),
      ),
    );
  }

  @override
  Future<pw.Document> generatePDF(CVData cvData, {String? locale}) async {
    final pdf = pw.Document();
    final fonts = await loadFonts();
    final profileImage = await _tryLoadProfileImage(
      cvData.personalInfo.profileImagePath,
    );
    final currentLocale = locale ?? 'en';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          // Header with name and contact
          _buildHeader(cvData, fonts, profileImage, currentLocale),
          pw.SizedBox(height: 12),

          // Professional summary
          if (cvData.summary != null && cvData.summary!.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'summary',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              cvData.summary!,
              style: pw.TextStyle(
                font: fonts.regularFont,
                fontSize: _adaptFontSize(cvData.summary!, 9),
                color: _colors.text,
                lineSpacing: 1.4,
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          // Work experience
          if (cvData.workExperiences.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'workExperience',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            ...cvData.workExperiences.map(
              (exp) => _buildWorkExperience(exp, fonts, currentLocale),
            ),
          ],

          // Education
          if (cvData.educations.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'education',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            ...cvData.educations.map(
              (edu) => _buildEducation(edu, fonts, currentLocale),
            ),
          ],

          // Skills
          if (cvData.skills.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'skills',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            _buildSkillsGrid(cvData.skills, fonts, currentLocale),
            pw.SizedBox(height: 12),
          ],

          // Languages
          if (cvData.languages.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'languages',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            _buildLanguages(cvData.languages, fonts, currentLocale),
          ],

          // Projects
          if (cvData.projects.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'projects',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            ...cvData.projects.map(
              (proj) => _buildProject(proj, fonts, currentLocale),
            ),
          ],

          // Certificates
          if (cvData.certificates.isNotEmpty) ...[
            _buildSection(
              TemplateLocalizations.translate(
                'certificates',
                currentLocale,
              ).toUpperCase(),
              fonts.boldFont!,
            ),
            pw.SizedBox(height: 6),
            ...cvData.certificates.map(
              (cert) => _buildCertificate(cert, fonts, currentLocale),
            ),
          ],
        ],
      ),
    );

    return pdf;
  }

  /// Build header section
  pw.Widget _buildHeader(
    CVData cvData,
    TemplateFonts fonts,
    pw.ImageProvider? profileImage,
    String locale,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left side - Name and contact
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  cvData.personalInfo.fullName,
                  style: pw.TextStyle(
                    font: fonts.boldFont,
                    fontSize: 22,
                    color: _colors.primary,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              // Contact info
              pw.Wrap(
                spacing: 15,
                runSpacing: 5,
                children: [
                  _contactItem(cvData.personalInfo.email, fonts.regularFont!),
                  _contactItem(cvData.personalInfo.phone, fonts.regularFont!),
                  if (cvData.personalInfo.city != null)
                    _contactItem(
                      '${cvData.personalInfo.city}, ${cvData.personalInfo.country}',
                      fonts.regularFont!,
                    ),
                  if (cvData.personalInfo.linkedIn != null)
                    _contactItem(
                      cvData.personalInfo.linkedIn!,
                      fonts.regularFont!,
                    ),
                  if (cvData.personalInfo.github != null)
                    _contactItem(
                      cvData.personalInfo.github!,
                      fonts.regularFont!,
                    ),
                ],
              ),
            ],
          ),
        ),
        // Right side - Profile photo (optional)
        if (profileImage != null)
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: _colors.accent, width: 2),
            ),
            child: pw.ClipOval(
              child: pw.Image(profileImage, fit: pw.BoxFit.cover),
            ),
          ),
      ],
    );
  }

  /// Contact item widget
  pw.Widget _contactItem(String text, pw.Font font) {
    // Check if text is a URL (contains common URL patterns)
    final isUrl =
        text.contains('linkedin.com') ||
        text.contains('github.com') ||
        text.contains('.com') ||
        text.contains('.dev') ||
        text.contains('.org') ||
        text.startsWith('http');

    if (isUrl) {
      // Ensure URL has protocol
      final url = text.startsWith('http') ? text : 'https://$text';

      return pw.UrlLink(
        destination: url,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 9,
            color: _colors.accent,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      );
    }

    return pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 9, color: _colors.secondary),
    );
  }

  /// Section title
  pw.Widget _buildSection(String title, pw.Font boldFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
              color: _colors.accent,
              letterSpacing: 0.8,
            ),
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 3),
            height: 1,
            width: double.infinity,
            color: _colors.accent.shade(0.3),
          ),
        ],
      ),
    );
  }

  /// Work experience item
  pw.Widget _buildWorkExperience(
    WorkExperience exp,
    TemplateFonts fonts,
    String locale,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${exp.jobTitle} at ${exp.company}',
                style: pw.TextStyle(
                  font: fonts.mediumFont ?? fonts.boldFont,
                  fontSize: 10,
                  color: _colors.text,
                ),
              ),
              pw.Text(
                _formatDateRange(
                  exp.startDate,
                  exp.endDate,
                  exp.isCurrentJob,
                  locale,
                ),
                style: pw.TextStyle(
                  font: fonts.regularFont,
                  fontSize: 9,
                  color: _colors.textLight,
                ),
              ),
            ],
          ),
          if (exp.location != null)
            pw.Text(
              exp.location!,
              style: pw.TextStyle(
                font: fonts.lightFont,
                fontSize: 9,
                color: _colors.textLight,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          if (exp.description != null && exp.description!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              exp.description!,
              style: pw.TextStyle(
                font: fonts.regularFont,
                fontSize: _adaptFontSize(exp.description!, 9),
                color: _colors.text,
                lineSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Education item
  pw.Widget _buildEducation(Education edu, TemplateFonts fonts, String locale) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                edu.degree,
                style: pw.TextStyle(
                  font: fonts.mediumFont ?? fonts.boldFont,
                  fontSize: 10,
                  color: _colors.text,
                ),
              ),
              pw.Text(
                _formatDateRange(
                  edu.startDate,
                  edu.endDate,
                  edu.isCurrentStudy,
                  locale,
                ),
                style: pw.TextStyle(
                  font: fonts.regularFont,
                  fontSize: 9,
                  color: _colors.textLight,
                ),
              ),
            ],
          ),
          pw.Text(
            edu.institution,
            style: pw.TextStyle(
              font: fonts.regularFont,
              fontSize: 9,
              color: _colors.text,
            ),
          ),
          if (edu.location != null)
            pw.Text(
              edu.location!,
              style: pw.TextStyle(
                font: fonts.lightFont,
                fontSize: 8,
                color: _colors.textLight,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  /// Skills grid
  pw.Widget _buildSkillsGrid(
    List<Skill> skills,
    TemplateFonts fonts,
    String locale,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: skills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _colors.accent.shade(0.3)),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
          ),
          child: pw.Text(
            '${skill.name} • ${skill.level.getLocalizedDisplayName(locale)}',
            style: pw.TextStyle(
              font: fonts.regularFont,
              fontSize: 8,
              color: _colors.text,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Languages list
  pw.Widget _buildLanguages(
    List<Language> languages,
    TemplateFonts fonts,
    String locale,
  ) {
    return pw.Row(
      children: languages.map((lang) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(right: 16),
          child: pw.Text(
            '${lang.name}: ${lang.level.getLocalizedDisplayName(locale)}',
            style: pw.TextStyle(
              font: fonts.regularFont,
              fontSize: 9,
              color: _colors.text,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Project item
  pw.Widget _buildProject(Project project, TemplateFonts fonts, String locale) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                project.name,
                style: pw.TextStyle(
                  font: fonts.mediumFont ?? fonts.boldFont,
                  fontSize: 10,
                  color: _colors.text,
                ),
              ),
              pw.Text(
                _formatDateRange(
                  project.startDate,
                  project.endDate,
                  project.isOngoing,
                  locale,
                ),
                style: pw.TextStyle(
                  font: fonts.regularFont,
                  fontSize: 9,
                  color: _colors.textLight,
                ),
              ),
            ],
          ),
          if (project.technologies.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                project.technologies.join(', '),
                style: pw.TextStyle(
                  font: fonts.lightFont,
                  fontSize: 8,
                  color: _colors.textLight,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          if (project.description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              project.description,
              style: pw.TextStyle(
                font: fonts.regularFont,
                fontSize: _adaptFontSize(project.description, 9),
                color: _colors.text,
                lineSpacing: 1.2,
              ),
            ),
          ],
          if (project.url != null || project.githubUrl != null) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                if (project.url != null)
                  pw.Text(
                    '${project.url}',
                    style: pw.TextStyle(
                      font: fonts.regularFont,
                      fontSize: 8,
                      color: _colors.accent,
                    ),
                  ),
                if (project.url != null && project.githubUrl != null)
                  pw.SizedBox(width: 10),
                if (project.githubUrl != null)
                  pw.Text(
                    '${project.githubUrl}',
                    style: pw.TextStyle(
                      font: fonts.regularFont,
                      fontSize: 8,
                      color: _colors.secondary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Certificate item
  pw.Widget _buildCertificate(
    Certificate cert,
    TemplateFonts fonts,
    String locale,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                cert.name,
                style: pw.TextStyle(
                  font: fonts.mediumFont ?? fonts.boldFont,
                  fontSize: 10,
                  color: _colors.text,
                ),
              ),
              pw.Text(
                _formatMonthYear(cert.issueDate),
                style: pw.TextStyle(
                  font: fonts.regularFont,
                  fontSize: 9,
                  color: _colors.textLight,
                ),
              ),
            ],
          ),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              font: fonts.regularFont,
              fontSize: 9,
              color: _colors.text,
            ),
          ),
          if (cert.expiryDate != null)
            pw.Text(
              'Expires: ${_formatMonthYear(cert.expiryDate!)}',
              style: pw.TextStyle(
                font: fonts.lightFont,
                fontSize: 8,
                color: _colors.textLight,
              ),
            ),
          if (cert.credentialId != null)
            pw.Text(
              'ID: ${cert.credentialId}',
              style: pw.TextStyle(
                font: fonts.lightFont,
                fontSize: 8,
                color: _colors.textLight,
              ),
            ),
          if (cert.url != null)
            pw.Text(
              cert.url!,
              style: pw.TextStyle(
                font: fonts.regularFont,
                fontSize: 8,
                color: _colors.accent,
              ),
            ),
        ],
      ),
    );
  }

  /// Try to load a profile image
  Future<pw.ImageProvider?> _tryLoadProfileImage(
    String? profileImagePath,
  ) async {
    if (profileImagePath == null || profileImagePath.isEmpty) return null;
    try {
      if (profileImagePath.startsWith('data:image/')) {
        final base64Data = profileImagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        return pw.MemoryImage(bytes);
      }

      final base64Like = RegExp(r'^[A-Za-z0-9+/=]+$');
      if (profileImagePath.length > 100 &&
          base64Like.hasMatch(profileImagePath)) {
        final bytes = base64Decode(profileImagePath);
        return pw.MemoryImage(bytes);
      }

      if (profileImagePath.startsWith('http') ||
          profileImagePath.startsWith('blob:')) {
        try {
          final img = await networkImage(profileImagePath);
          return img;
        } catch (_) {}
      }

      final asset = await rootBundle.load(profileImagePath);
      return pw.MemoryImage(asset.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  /// Format date utilities
  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDateRange(
    DateTime start,
    DateTime? end,
    bool isCurrent,
    String locale,
  ) {
    final startStr = _formatMonthYear(start);
    if (isCurrent) {
      return '$startStr - ${TemplateLocalizations.translate('present', locale)}';
    }
    if (end != null) return '$startStr - ${_formatMonthYear(end)}';
    return startStr;
  }

  /// Adapt font size by crude heuristic based on text length
  double _adaptFontSize(String text, double base) {
    final length = text.length;
    if (length > 600) return base - 2.0;
    if (length > 400) return base - 1.5;
    if (length > 250) return base - 1.0;
    if (length > 150) return base - 0.5;
    return base;
  }
}
