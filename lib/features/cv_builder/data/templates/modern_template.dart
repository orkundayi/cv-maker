import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'cv_template.dart';
import 'template_localizations.dart';
import '../../domain/cv_data.dart';

/// Modern CV template with sidebar design
class ModernTemplate extends CVTemplate {
  @override
  String get id => 'modern_sidebar';

  @override
  String get name => 'Modern';

  @override
  String get description =>
      'Professional modern CV with colored sidebar for personal info and skills';

  @override
  String get previewImage => 'assets/templates/modern_sidebar_preview.png';

  // Template specific colors
  static const _colors = TemplateColors(
    primary: PdfColor.fromInt(0xFF2C3E50), // Dark blue-gray for sidebar
    secondary: PdfColor.fromInt(0xFF34495E), // Darker shade for headings
    accent: PdfColor.fromInt(0xFF34495E),
    text: PdfColor.fromInt(0xFF2C3E50),
    textLight: PdfColor.fromInt(0xB3FFFFFF), // 70% opacity white
    background: PdfColor.fromInt(0x4DFFFFFF), // 30% opacity white
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
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.zero,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Row(
              children: [
                pw.Container(width: 200, color: _colors.primary),
                pw.Expanded(child: pw.SizedBox()),
              ],
            ),
          ),
        ),
        build: (context) => [
          // Two-column flowing layout across pages
          pw.Partitions(
            children: [
              pw.Partition(
                width: 200,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: _buildSidebar(
                    cvData,
                    fonts,
                    profileImage,
                    currentLocale,
                  ),
                ),
              ),
              pw.Partition(
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: _buildMainContent(cvData, fonts, currentLocale),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Build left sidebar content
  pw.Widget _buildSidebar(
    CVData cvData,
    TemplateFonts fonts,
    pw.ImageProvider? profileImage,
    String locale,
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
              child: pw.ClipOval(
                child: pw.Image(profileImage, fit: pw.BoxFit.cover),
              ),
            ),
          ),

        // Personal section
        _sidebarSection(
          TemplateLocalizations.translate('personal', locale),
          fonts.boldFont!,
        ),
        pw.SizedBox(height: 12),

        _sidebarItem(
          TemplateLocalizations.translate('address', locale),
          '${cvData.personalInfo.city ?? ''}, ${cvData.personalInfo.country ?? ''}',
          fonts.regularFont!,
          _colors.textLight,
        ),
        _sidebarItem(
          TemplateLocalizations.translate('phoneNumber', locale),
          cvData.personalInfo.phone,
          fonts.regularFont!,
          _colors.textLight,
        ),
        _sidebarItem(
          TemplateLocalizations.translate('email', locale),
          cvData.personalInfo.email,
          fonts.regularFont!,
          _colors.textLight,
        ),
        _sidebarItem(
          'Location',
          '${cvData.personalInfo.city ?? ''}, ${cvData.personalInfo.country ?? ''}',
          fonts.regularFont!,
          _colors.textLight,
        ),
        if (cvData.personalInfo.github != null)
          _sidebarItem(
            TemplateLocalizations.translate('github', locale),
            cvData.personalInfo.github!,
            fonts.regularFont!,
            _colors.textLight,
          ),
        if (cvData.personalInfo.linkedIn != null)
          _sidebarItem(
            TemplateLocalizations.translate('linkedIn', locale),
            cvData.personalInfo.linkedIn!,
            fonts.regularFont!,
            _colors.textLight,
          ),
        if (cvData.personalInfo.website != null)
          _sidebarItem(
            'Website',
            cvData.personalInfo.website!,
            fonts.regularFont!,
            _colors.textLight,
          ),

        pw.SizedBox(height: 20),

        // Languages section
        if (cvData.languages.isNotEmpty) ...[
          _sidebarSection(
            TemplateLocalizations.translate('languages', locale),
            fonts.boldFont!,
          ),
          pw.SizedBox(height: 8),
          ...cvData.languages.map(
            (lang) => _sidebarLanguageItem(lang, fonts.regularFont!, locale),
          ),
        ],

        // Skills section
        if (cvData.skills.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _sidebarSection(
            TemplateLocalizations.translate('skills', locale),
            fonts.boldFont!,
          ),
          pw.SizedBox(height: 8),
          ...cvData.skills.map(
            (skill) => _sidebarSkillItem(skill, fonts.regularFont!, locale),
          ),
        ],
      ],
    );
  }

  /// Build right main content area
  pw.Widget _buildMainContent(
    CVData cvData,
    TemplateFonts fonts,
    String locale,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Name header
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Auto-shrink name to fit available width
              pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  cvData.personalInfo.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    font: fonts.boldFont,
                    fontSize: 26,
                    color: _colors.text,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 3),
                height: 2.5,
                width: double.infinity,
                color: _colors.accent,
              ),
            ],
          ),
        ),

        // Professional summary
        if (cvData.summary != null && cvData.summary!.isNotEmpty) ...[
          _mainSection(
            TemplateLocalizations.translate('summary', locale),
            fonts.boldFont!,
            _colors.accent,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            cvData.summary!,
            style: pw.TextStyle(
              font: fonts.regularFont,
              fontSize: _adaptFontSize(cvData.summary!, 8),
              color: _colors.text,
              lineSpacing: 1.4,
            ),
          ),
          pw.SizedBox(height: 6),
        ],

        // Work experience
        if (cvData.workExperiences.isNotEmpty) ...[
          _mainSection(
            TemplateLocalizations.translate('workExperience', locale),
            fonts.boldFont!,
            _colors.accent,
          ),
          pw.SizedBox(height: 6),
          ...cvData.workExperiences.map(
            (exp) => _workExperienceItem(
              exp,
              fonts.regularFont!,
              fonts.mediumFont!,
              _colors.text,
            ),
          ),
        ],

        // Education
        if (cvData.educations.isNotEmpty) ...[
          _mainSection(
            TemplateLocalizations.translate('education', locale),
            fonts.boldFont!,
            _colors.accent,
          ),
          pw.SizedBox(height: 6),
          ...cvData.educations.map(
            (edu) => _educationItem(
              edu,
              fonts.regularFont!,
              fonts.mediumFont!,
              _colors.text,
            ),
          ),
        ],

        // Projects
        if (cvData.projects.isNotEmpty) ...[
          _mainSection(
            TemplateLocalizations.translate('projects', locale),
            fonts.boldFont!,
            _colors.accent,
          ),
          pw.SizedBox(height: 6),
          ...cvData.projects.map(
            (proj) => _projectItem(
              proj,
              fonts.regularFont!,
              fonts.mediumFont!,
              _colors.text,
            ),
          ),
        ],

        // Certificates
        if (cvData.certificates.isNotEmpty) ...[
          _mainSection(
            TemplateLocalizations.translate('certificates', locale),
            fonts.boldFont!,
            _colors.accent,
          ),
          pw.SizedBox(height: 6),
          ...cvData.certificates.map(
            (cert) => _certificateItem(
              cert,
              fonts.regularFont!,
              fonts.mediumFont!,
              _colors.text,
            ),
          ),
        ],
      ],
    );
  }

  /// Sidebar section title
  pw.Widget _sidebarSection(String title, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.white, width: 1),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 12,
          color: PdfColors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  /// Sidebar key-value item
  pw.Widget _sidebarItem(
    String label,
    String value,
    pw.Font font,
    PdfColor labelColor,
  ) {
    if (value.isEmpty) return pw.SizedBox();

    // Check if value is a URL (contains common URL patterns)
    final isUrl =
        value.contains('linkedin.com') ||
        value.contains('github.com') ||
        value.contains('.com') ||
        value.contains('.dev') ||
        value.contains('.org') ||
        value.startsWith('http');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 8, color: labelColor),
          ),
          pw.SizedBox(height: 1),
          if (isUrl) ...[
            // Make URLs clickable
            pw.UrlLink(
              destination: value.startsWith('http') ? value : 'https://$value',
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  color: PdfColors.white,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
          ] else ...[
            pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Sidebar language item
  pw.Widget _sidebarLanguageItem(
    Language lang,
    pw.Font regularFont,
    String locale,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lang.name,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            lang.level.getLocalizedDisplayName(locale),
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: PdfColors.white.shade(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Sidebar skill item with level text
  pw.Widget _sidebarSkillItem(Skill skill, pw.Font regularFont, String locale) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            skill.name,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            skill.level.getLocalizedDisplayName(locale),
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 7,
              color: PdfColors.white.shade(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Main content section title
  pw.Widget _mainSection(String title, pw.Font boldFont, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 3),
            height: 1,
            width: 40,
            color: color,
          ),
        ],
      ),
    );
  }

  /// Work experience item
  pw.Widget _workExperienceItem(
    WorkExperience exp,
    pw.Font regularFont,
    pw.Font mediumFont,
    PdfColor textDark,
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
                exp.jobTitle,
                style: pw.TextStyle(
                  font: mediumFont,
                  fontSize: 11,
                  color: textDark,
                ),
              ),
              pw.Text(
                _formatDateRange(exp.startDate, exp.endDate, exp.isCurrentJob),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: textDark.shade(0.3),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${exp.company}${exp.location != null ? ", ${exp.location}" : ""}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: textDark.shade(0.2),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          if (exp.description != null && exp.description!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              exp.description!,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: _adaptFontSize(exp.description!, 8),
                color: textDark,
                lineSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Education item
  pw.Widget _educationItem(
    Education edu,
    pw.Font regularFont,
    pw.Font mediumFont,
    PdfColor textDark,
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
                edu.degree,
                style: pw.TextStyle(
                  font: mediumFont,
                  fontSize: 11,
                  color: textDark,
                ),
              ),
              pw.Text(
                _formatDateRange(
                  edu.startDate,
                  edu.endDate,
                  edu.isCurrentStudy,
                ),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: textDark.shade(0.3),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              '${edu.institution}${edu.location != null ? ", ${edu.location}" : ""}',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
                color: textDark.shade(0.2),
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Project item in main content
  pw.Widget _projectItem(
    Project proj,
    pw.Font regularFont,
    pw.Font mediumFont,
    PdfColor textDark,
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
                proj.name,
                style: pw.TextStyle(
                  font: mediumFont,
                  fontSize: 11,
                  color: textDark,
                ),
              ),
              pw.Text(
                _formatDateRange(proj.startDate, proj.endDate, proj.isOngoing),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: textDark.shade(0.3),
                ),
              ),
            ],
          ),
          if (proj.technologies.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1),
              child: pw.Text(
                proj.technologies.join(', '),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
                  color: textDark.shade(0.4),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          if (proj.description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              proj.description,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: _adaptFontSize(proj.description, 8),
                color: textDark,
                lineSpacing: 1.2,
              ),
            ),
          ],
          if (proj.url != null || proj.githubUrl != null) ...[
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                if (proj.url != null)
                  _linkText(proj.url!, regularFont, textDark),
                if (proj.url != null && proj.githubUrl != null)
                  pw.SizedBox(width: 10),
                if (proj.githubUrl != null)
                  _linkText(proj.githubUrl!, regularFont, textDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Certificate item in main content
  pw.Widget _certificateItem(
    Certificate cert,
    pw.Font regularFont,
    pw.Font mediumFont,
    PdfColor textDark,
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
                  font: mediumFont,
                  fontSize: 11,
                  color: textDark,
                ),
              ),
              pw.Text(
                _formatMonthYear(cert.issueDate),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: textDark.shade(0.3),
                ),
              ),
            ],
          ),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: textDark.shade(0.6),
            ),
          ),
          if (cert.expiryDate != null)
            pw.Text(
              'Expires: ${_formatMonthYear(cert.expiryDate!)}',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: textDark.shade(0.4),
              ),
            ),
          if (cert.credentialId != null)
            pw.Text(
              'ID: ${cert.credentialId}',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: textDark.shade(0.4),
              ),
            ),
          if (cert.url != null)
            _linkText(cert.url!, regularFont, textDark.shade(0.6)),
        ],
      ),
    );
  }

  /// Short link with label, truncates long URLs
  pw.Widget _linkText(String url, pw.Font font, PdfColor color) {
    final display = url.length > 40 ? '${url.substring(0, 37)}...' : url;
    return pw.RichText(
      text: pw.TextSpan(
        text: display,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          color: _colors.accent,
          decoration: pw.TextDecoration.underline,
        ),
        // Note: printing package clickable annotations handled by Printing.layoutPdf
      ),
    );
  }

  /// Adapt font size by crude heuristic based on length
  double _adaptFontSize(String text, double base) {
    final length = text.length;
    if (length > 600) return base - 2.0;
    if (length > 400) return base - 1.5;
    if (length > 250) return base - 1.0;
    if (length > 150) return base - 0.5;
    return base;
  }

  /// Try to load a profile image from base64 data URL or asset path
  Future<pw.ImageProvider?> _tryLoadProfileImage(
    String? profileImagePath,
  ) async {
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
      if (profileImagePath.length > 100 &&
          base64Like.hasMatch(profileImagePath)) {
        final bytes = base64Decode(profileImagePath);
        return pw.MemoryImage(bytes);
      }

      // Case 3: http/https or blob URL (web) – fetch via network
      if (profileImagePath.startsWith('http') ||
          profileImagePath.startsWith('blob:')) {
        try {
          final img = await networkImage(profileImagePath);
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

  String _formatDateRange(DateTime start, DateTime? end, bool isCurrent) {
    final startStr = _formatMonthYear(start);
    if (isCurrent) return '$startStr - Present';
    if (end != null) return '$startStr - ${_formatMonthYear(end)}';
    return startStr;
  }
}
