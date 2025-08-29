import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:printing/printing.dart';
import '../../../../l10n/app_localizations.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.03),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.spacingL),
            _buildPdfPreview(context, cvData, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cvData = ref.watch(cvDataProvider);
    final l10n = AppLocalizations.of(context)!;
    final screenType = ResponsiveUtils.getScreenType(context);
    final isMobile = screenType == ScreenType.mobile;

    return Container(
      padding: EdgeInsets.all(
        isMobile ? AppConstants.spacingM : AppConstants.spacingL,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.eye(PhosphorIconsStyle.bold),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cvPreview,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.previewDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) _buildExportButton(context, cvData),
            ],
          ),

          if (isMobile) ...[
            const SizedBox(height: AppConstants.spacingL),
            _buildExportButton(context, cvData),
          ],

          const SizedBox(height: AppConstants.spacingL),

          // Template selector
          _buildModernTemplateSelector(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildModernTemplateSelector(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.palette(),
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.chooseTemplate,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_availableTemplates.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacingM),

        // Template grid
        _buildResponsiveTemplateGrid(context, isMobile),
      ],
    );
  }

  Widget _buildResponsiveTemplateGrid(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Mobile: Single column
      return Column(
        children: _availableTemplates
            .map((template) => _buildTemplateCard(template, true))
            .toList(),
      );
    }

    // Desktop/Tablet: Smart responsive grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const spacing = AppConstants.spacingM;

        int columns;
        double minCardWidth;

        // Smart column calculation based on screen width
        if (screenWidth > 1200) {
          // Large desktop: 3 columns, wider cards
          columns = 3;
          minCardWidth = 320.0;
        } else if (screenWidth > 900) {
          // Medium desktop: 2-3 columns
          columns = (screenWidth > 1000) ? 3 : 2;
          minCardWidth = 300.0;
        } else if (screenWidth > 600) {
          // Tablet: 2 columns
          columns = 2;
          minCardWidth = 280.0;
        } else {
          // Small tablet: 1 column
          columns = 1;
          minCardWidth = screenWidth - (spacing * 2);
        }

        // Don't exceed available templates
        columns = columns.clamp(1, _availableTemplates.length);

        // Calculate card width with even distribution
        final cardWidth = (screenWidth - (spacing * (columns - 1))) / columns;
        final finalCardWidth = cardWidth.clamp(minCardWidth, double.infinity);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: _availableTemplates.map((template) {
            return SizedBox(
              width: finalCardWidth,
              child: _buildTemplateCard(template, false),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTemplateCard(CVTemplate template, bool isMobile) {
    final isSelected = template.id == _selectedTemplateId;

    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateId = template.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: isMobile ? AppConstants.spacingS : 0),
        padding: EdgeInsets.all(
          isMobile ? AppConstants.spacingM : AppConstants.spacingL,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Theme.of(context).dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Icon(
                    _getTemplateIcon(template.id),
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedTemplateName(context, template.id),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _localizedTemplateDescription(context, template.id),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppConstants.spacingS),

            // Template features
            Wrap(
              spacing: 4,
              children: _getTemplateFeatures(template.id)
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTemplateIcon(String templateId) {
    switch (templateId) {
      case 'modern_sidebar':
        return PhosphorIcons.sidebar();
      case 'minimal_clean':
        return PhosphorIcons.fileText();
      case 'professional_corporate':
        return PhosphorIcons.briefcase();
      default:
        return PhosphorIcons.fileText();
    }
  }

  List<String> _getTemplateFeatures(String templateId) {
    final l10n = AppLocalizations.of(context)!;
    switch (templateId) {
      case 'modern_sidebar':
        return [l10n.modern, 'Sidebar', 'Colorful'];
      case 'minimal_clean':
        return ['Clean', 'Simple', 'ATS-Friendly'];
      case 'professional_corporate':
        return [l10n.professional, 'Corporate', 'Classic'];
      default:
        return ['Standard'];
    }
  }

  String _localizedTemplateName(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'modern_sidebar':
        return l10n.modern; // concise label
      case 'minimal_clean':
        return l10n.minimal;
      case 'professional_corporate':
        return l10n.professional;
      default:
        return id;
    }
  }

  String _localizedTemplateDescription(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'modern_sidebar':
        return l10n.modernSidebarDescription;
      case 'minimal_clean':
        return l10n.minimalCleanDescription;
      case 'professional_corporate':
        return l10n.professionalCorporateDescription;
      default:
        return '';
    }
  }

  Widget _buildExportButton(BuildContext context, CVData cvData) {
    return ElevatedButton.icon(
      onPressed: cvData.hasContent && !_isExporting
          ? () => _exportPdf(context, cvData)
          : null,
      icon: _isExporting
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : Icon(PhosphorIcons.downloadSimple()),
      label: Text(
        _isExporting
            ? AppLocalizations.of(context)!.exportingPdf
            : AppLocalizations.of(context)!.exportPdf,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  // Build PDF preview using the same PDF generation logic
  Widget _buildPdfPreview(BuildContext context, CVData cvData, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final previewHeight = isMobile ? 600.0 : 800.0;

    if (!cvData.hasContent) {
      return _buildEmptyState(context, isMobile);
    }

    return Container(
      height: previewHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Preview header
          Container(
            padding: EdgeInsets.all(
              isMobile ? AppConstants.spacingM : AppConstants.spacingL,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.fileText(PhosphorIconsStyle.bold),
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.cvPreview,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showClearAllDialog(context),
                  icon: Icon(PhosphorIcons.trash(), size: 18),
                  tooltip: l10n.clearAllData,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getSelectedTemplateName(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PDF Preview content
          Expanded(
            child: Container(
              margin: EdgeInsets.all(
                isMobile ? AppConstants.spacingS : AppConstants.spacingM,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfPreview(
                  build: (format) async {
                    // Use the selected template to generate PDF with current locale
                    final currentLocale = Localizations.localeOf(
                      context,
                    ).languageCode;
                    final pdf = await CVExportService.generatePDF(
                      cvData,
                      templateId: _selectedTemplateId,
                      locale: currentLocale,
                    );
                    return pdf.save();
                  },
                  allowPrinting: false,
                  allowSharing: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  maxPageWidth: screenWidth,
                  pdfFileName:
                      'cv_${cvData.personalInfo.lastName.toLowerCase()}_preview',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: isMobile ? 400 : 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.fileText(),
                size: 48,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            Text(
              l10n.cvPreview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: AppConstants.spacingS),

            Text(
              l10n.previewDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Responsive button layout
            if (isMobile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(cvDataProvider.notifier).loadDemoData();
                          if (mounted) {
                            final l10n = AppLocalizations.of(context)!;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.demoDataLoaded),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: Icon(PhosphorIcons.lightbulb()),
                        label: Text(AppLocalizations.of(context)!.loadDemoData),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showClearAllDialog(context);
                        },
                        icon: Icon(PhosphorIcons.trash(), color: Colors.red),
                        label: Text(
                          l10n.clearAllData,
                          style: const TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(cvDataProvider.notifier).loadDemoData();
                      if (mounted) {
                        final l10n = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.demoDataLoaded),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: Icon(PhosphorIcons.lightbulb()),
                    label: Text(AppLocalizations.of(context)!.loadDemoData),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showClearAllDialog(context);
                    },
                    icon: Icon(PhosphorIcons.trash(), color: Colors.red),
                    label: Text(
                      l10n.clearAllData,
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getSelectedTemplateName() {
    final template = _availableTemplates.firstWhere(
      (t) => t.id == _selectedTemplateId,
      orElse: () => _availableTemplates.first,
    );
    return template.name;
  }

  // Export Methods
  Future<void> _exportPdf(BuildContext context, CVData cvData) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final fileName =
          'cv_${cvData.personalInfo.firstName.toLowerCase()}_${cvData.personalInfo.lastName.toLowerCase()}';
      final currentLocale = Localizations.localeOf(context).languageCode;
      await CVExportService.exportToPDF(
        cvData,
        fileName: fileName,
        templateId: _selectedTemplateId,
        locale: currentLocale,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.pdfExported),
              ],
            ),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(PhosphorIcons.warning(), color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Export failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              Icon(PhosphorIcons.warning(), size: 24),
              const SizedBox(width: 8),
              Text(l10n.clearAllData),
            ],
          ),
          content: Text(l10n.clearAllConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          PhosphorIcons.checkCircle(),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.allDataCleared),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );
  }
}
