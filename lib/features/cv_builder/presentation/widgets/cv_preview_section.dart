import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/cv_provider.dart';
import '../../data/services/cv_export_service.dart';
import '../../data/templates/cv_template.dart';
import '../../domain/cv_data.dart';

/// CV Preview and Export Section
class CVPreviewSection extends ConsumerStatefulWidget {
  const CVPreviewSection({super.key});

  @override
  ConsumerState<CVPreviewSection> createState() => _CVPreviewSectionState();
}

class _CVPreviewSectionState extends ConsumerState<CVPreviewSection> {
  bool _isExporting = false;
  String _selectedTemplateId = 'modern_sidebar'; // Default template
  List<CVTemplate> _availableTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    setState(() {
      _availableTemplates = CVExportService.getAvailableTemplates();
      if (_availableTemplates.isNotEmpty) {
        _selectedTemplateId = _availableTemplates.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cvData = ref.watch(cvDataProvider);
    final isMobile = ResponsiveUtils.isMobile(context);

    return ResponsiveLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppConstants.spacingL),
          _buildPdfPreview(context, cvData, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cvData = ref.watch(cvDataProvider);
    final screenType = ResponsiveUtils.getScreenType(context);

    // Mobile layout - stack vertically
    if (screenType == ScreenType.mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              Icon(PhosphorIcons.eye(), color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CV Önizlemesi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _buildExportButton(context, cvData),
            ],
          ),
          const SizedBox(height: 16),
          // Şablon seçici ve export butonu
          _buildTemplateSelector(context),
        ],
      );
    }

    // Tablet/Desktop layout - horizontal with flexible template selector
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol taraf - Başlık
            Row(
              children: [
                Icon(PhosphorIcons.eye(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'CV Önizlemesi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Sağ taraf - Export butonu
            _buildExportButton(context, cvData),
          ],
        ),
        const SizedBox(height: 16),
        // Şablon seçici - full width on tablet/desktop
        _buildTemplateSelector(context),
      ],
    );
  }

  // Build PDF preview using the same PDF generation logic
  Widget _buildPdfPreview(BuildContext context, CVData cvData, bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final previewHeight = isMobile ? 800.0 : 1200.0;

    return Container(
      height: previewHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PdfPreview(
          build: (format) async {
            // Use the selected template to generate PDF
            final pdf = await CVExportService.generatePDF(cvData, templateId: _selectedTemplateId);
            return pdf.save();
          },
          allowPrinting: false,
          allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          maxPageWidth: screenWidth,
          pdfFileName: 'cv_${cvData.personalInfo.lastName.toLowerCase()}_preview',
        ),
      ),
    );
  }

  // Export Methods
  Future<void> _exportToPDF(CVData cvData) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final fileName = 'cv_${cvData.personalInfo.lastName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
      await CVExportService.exportToPDF(cvData, fileName: fileName, templateId: _selectedTemplateId);
    } catch (e) {
      // Optionally show a SnackBar in the future
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Modern export button for header
  Widget _buildExportButton(BuildContext context, CVData cvData) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.responsive(context, mobile: 8, tablet: 12, desktop: 12)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: ResponsiveUtils.responsive(context, mobile: 4, tablet: 8, desktop: 8),
            offset: Offset(0, ResponsiveUtils.responsive(context, mobile: 2, tablet: 4, desktop: 4)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveUtils.responsive(context, mobile: 8, tablet: 12, desktop: 12)),
          onTap: _isExporting ? null : () => _exportToPDF(cvData),
          child: Padding(
            padding: ResponsiveUtils.responsive(
              context,
              mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isExporting)
                  SizedBox(
                    width: ResponsiveUtils.responsive(context, mobile: 14, tablet: 16, desktop: 16),
                    height: ResponsiveUtils.responsive(context, mobile: 14, tablet: 16, desktop: 16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold),
                    color: Colors.white,
                    size: ResponsiveUtils.responsive(context, mobile: 16, tablet: 18, desktop: 20),
                  ),
                SizedBox(width: ResponsiveUtils.responsive(context, mobile: 6, tablet: 8, desktop: 8)),
                Text(
                  _isExporting
                      ? 'İndiriliyor...'
                      : ResponsiveUtils.responsive(context, mobile: 'İndir', tablet: 'PDF İndir', desktop: 'PDF İndir'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.responsive(context, mobile: 12, tablet: 14, desktop: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Template selector widget
  Widget _buildTemplateSelector(BuildContext context) {
    if (_availableTemplates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 56),
      padding: ResponsiveUtils.responsive(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        desktop: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColor.withOpacity(0.05),
      ),
      child: DropdownButton<String>(
        value: _selectedTemplateId,
        underline: const SizedBox.shrink(),
        isDense: true,
        isExpanded: true,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: ResponsiveUtils.responsive(context, mobile: 13, tablet: 14, desktop: 14),
        ),
        icon: Icon(
          PhosphorIcons.caretDown(),
          size: ResponsiveUtils.responsive(context, mobile: 14, tablet: 16, desktop: 16),
          color: Theme.of(context).primaryColor,
        ),
        items: _availableTemplates.map((template) {
          return DropdownMenuItem<String>(
            value: template.id,
            child: Container(
              constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.file(), size: 16, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedTemplateId = newValue;
            });
          }
        },
      ),
    );
  }
}
