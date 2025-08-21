//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Removed heavy preview dependencies
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/cv_provider.dart';
import '../../data/services/cv_export_service.dart';
// import '../../data/services/cv_storage_service.dart'; // Not used
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: AppConstants.spacingL),

          // Export Actions
          if (!isMobile) _buildExportActions(context, cvData),
          const SizedBox(height: AppConstants.spacingL),

          // Only export action (single download button)
          _buildSingleExportButton(context, cvData),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildExportActions(BuildContext context, CVData cvData) {
    return _buildSingleExportButton(context, cvData);
  }

  // Removed detailed preview – we keep only a single export button to simplify UI

  // Removed all preview helpers for a minimal UI

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

  // Single export button shown across layouts
  Widget _buildSingleExportButton(BuildContext context, CVData cvData) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : () => _exportToPDF(cvData),
        icon: _isExporting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(PhosphorIcons.filePdf()),
        label: Text(_isExporting ? 'Exporting...' : 'Export to PDF'),
      ),
    );
  }

  // Removed export/save option dialogs to keep UI minimal

  // Utility Methods
  //

  // Removed unused date range helper
}
