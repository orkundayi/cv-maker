import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/cv_provider.dart';
import '../../data/services/cv_export_service.dart';
import '../../domain/cv_data.dart';

/// CV Preview and Export Section
class CVPreviewSection extends ConsumerStatefulWidget {
  const CVPreviewSection({super.key});

  @override
  ConsumerState<CVPreviewSection> createState() => _CVPreviewSectionState();
}

class _CVPreviewSectionState extends ConsumerState<CVPreviewSection> {
  bool _isExporting = false;

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol taraf - Başlık
        Row(
          children: [
            Icon(PhosphorIcons.eye(), color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text('CV Önizlemesi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        // Sağ taraf - Export butonu
        _buildExportButton(context, cvData),
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
            // Use the same PDF generation logic from CVExportService
            final pdf = await CVExportService.generatePDF(cvData);
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
      await CVExportService.exportToPDF(cvData, fileName);
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isExporting ? null : () => _exportToPDF(cvData),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isExporting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _isExporting ? 'İndiriliyor...' : 'PDF İndir',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
