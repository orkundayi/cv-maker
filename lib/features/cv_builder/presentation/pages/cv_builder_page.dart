import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/theme_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/firestore_cv_service.dart';
import '../../domain/cv_data.dart';
import '../providers/cv_provider.dart';
import '../widgets/cv_section_navigation.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/summary_section.dart';
import '../widgets/work_experience_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/languages_section.dart';
import '../widgets/certificates_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/cv_preview_section.dart';

/// Main CV Builder page with responsive layout and step-by-step navigation
class CVBuilderPage extends ConsumerStatefulWidget {
  final String? cvId;

  const CVBuilderPage({super.key, this.cvId});

  @override
  ConsumerState<CVBuilderPage> createState() => _CVBuilderPageState();
}

class _CVBuilderPageState extends ConsumerState<CVBuilderPage> {
  final FirestoreCVService _cvService = FirestoreCVService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set the current CV ID and load data when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cvId != null) {
        ref.read(currentCVIdProvider.notifier).state = widget.cvId;
        ref.read(cvSaveStateProvider.notifier).state = CVSaveState.idle;
        _loadCVData();
      }
    });
  }

  Future<void> _loadCVData() async {
    final cvId = widget.cvId;
    if (cvId == null) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(
      data: (user) => user?.uid,
      orElse: () => null,
    );

    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final cvData = await _cvService.loadCVData(userId, cvId);

      if (cvData != null && mounted) {
        // Load data into provider
        ref.read(cvDataProvider.notifier).cvData = cvData;
        // Reset dirty state after loading
        ref.read(cvIsDirtyProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.cvSaveFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveToFirebase() async {
    final l10n = AppLocalizations.of(context)!;
    final cvId = ref.read(currentCVIdProvider);

    if (cvId == null) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(
      data: (user) => user?.uid,
      orElse: () => null,
    );

    if (userId == null) return;

    // Set saving state
    ref.read(cvSaveStateProvider.notifier).state = CVSaveState.saving;

    try {
      final cvData = ref.read(cvDataProvider);

      // Update the CV with current ID before saving
      final cvToSave = CVData(
        id: cvId,
        personalInfo: cvData.personalInfo,
        workExperiences: cvData.workExperiences,
        educations: cvData.educations,
        skills: cvData.skills,
        languages: cvData.languages,
        certificates: cvData.certificates,
        projects: cvData.projects,
        summary: cvData.summary,
        createdAt: cvData.createdAt,
      );

      await _cvService.saveCVData(userId, cvToSave);

      // Set success state
      ref.read(cvSaveStateProvider.notifier).state = CVSaveState.success;
      ref.read(cvIsDirtyProvider.notifier).state = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  PhosphorIconsRegular.check,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(l10n.cvSavedToCloud),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
      }

      // Reset to idle after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ref.read(cvSaveStateProvider.notifier).state = CVSaveState.idle;
      }
    } catch (e) {
      // Set error state
      ref.read(cvSaveStateProvider.notifier).state = CVSaveState.error;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  PhosphorIconsRegular.warning,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.cvSaveFailed}: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
      }

      // Reset to idle after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        ref.read(cvSaveStateProvider.notifier).state = CVSaveState.idle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = ref.watch(currentSectionProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveUtils.isMobile(context)
          ? _buildMobileLayout(context, currentSection)
          : _buildDesktopLayout(context, currentSection),
      bottomNavigationBar: ResponsiveUtils.isMobile(context) && !_isLoading
          ? _buildMobileNavigation(context, currentSection)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final languageNotifier = ref.read(languageProvider.notifier);
    final currentLocale = ref.watch(languageProvider);
    final colors = ref.colors;
    final isDirty = ref.watch(cvIsDirtyProvider);
    final saveState = ref.watch(cvSaveStateProvider);

    return AppBar(
      title: Row(
        children: [
          Icon(PhosphorIcons.fileText(), color: colors.primary, size: 28),
          const SizedBox(width: AppConstants.spacingM),
          Text(
            l10n.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ],
      ),
      actions: [
        // Save to Cloud Button
        _buildSaveButton(context, l10n, isDirty, saveState),

        const SizedBox(width: 8),

        // Language Toggle Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: languageNotifier.toggleLanguage,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.globe(), size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    currentLocale.languageCode == 'tr' ? 'TR' : 'EN',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Theme selector button (for both mobile and desktop)
        IconButton(
          onPressed: () => _showThemeSelector(context, l10n),
          icon: Icon(PhosphorIcons.palette(), color: colors.primary),
          tooltip: l10n.selectTheme,
        ),

        // Help button (for both mobile and desktop)
        IconButton(
          onPressed: () => _showHelpDialog(context, l10n),
          icon: Icon(PhosphorIcons.question(), color: colors.primary),
          tooltip: l10n.help,
        ),

        if (!ResponsiveUtils.isMobile(context)) ...[
          const SizedBox(width: AppConstants.spacingS),
        ],
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDirty,
    CVSaveState saveState,
  ) {
    final colors = ref.colors;

    // Determine button appearance based on state
    final bool isLoading = saveState == CVSaveState.saving;
    final bool isSuccess = saveState == CVSaveState.success;
    final bool isError = saveState == CVSaveState.error;
    final bool canSave = isDirty && !isLoading;

    Color buttonColor;
    Color textColor;
    IconData icon;
    String label;

    if (isLoading) {
      buttonColor = colors.primary.withOpacity(0.7);
      textColor = Colors.white;
      icon = PhosphorIconsRegular.cloudArrowUp;
      label = l10n.saving;
    } else if (isSuccess) {
      buttonColor = Colors.green;
      textColor = Colors.white;
      icon = PhosphorIconsRegular.check;
      label = l10n.saveToCloudButton;
    } else if (isError) {
      buttonColor = Theme.of(context).colorScheme.error;
      textColor = Colors.white;
      icon = PhosphorIconsRegular.warning;
      label = l10n.saveToCloudButton;
    } else if (isDirty) {
      buttonColor = colors.primary;
      textColor = Colors.white;
      icon = PhosphorIconsRegular.cloudArrowUp;
      label = l10n.saveToCloudButton;
    } else {
      buttonColor = colors.grey300;
      textColor = colors.grey500;
      icon = PhosphorIconsRegular.cloud;
      label = l10n.saveToCloudButton;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: canSave ? _saveToFirebase : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            disabledBackgroundColor: colors.grey200,
            disabledForegroundColor: colors.grey400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CVSection currentSection) {
    return ResponsiveLayout(
      child: _buildCurrentSection(context, currentSection),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CVSection currentSection) {
    final colors = ref.colors;
    return Row(
      children: [
        // Left Navigation Panel
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            border: Border(right: BorderSide(color: colors.border, width: 1)),
          ),
          child: CVSectionNavigation(
            currentSection: currentSection,
            onSectionChanged: (section) {
              ref.read(currentSectionProvider.notifier).state = section;
            },
          ),
        ),
        // Main Content Area
        Expanded(
          child: ResponsiveLayout(
            child: _buildCurrentSection(context, currentSection),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSection(BuildContext context, CVSection currentSection) {
    switch (currentSection) {
      case CVSection.personalInfo:
        return const PersonalInfoSection();
      case CVSection.summary:
        return const SummarySection();
      case CVSection.workExperience:
        return const WorkExperienceSection();
      case CVSection.education:
        return const EducationSection();
      case CVSection.skills:
        return const SkillsSection();
      case CVSection.languages:
        return const LanguagesSection();
      case CVSection.certificates:
        return const CertificatesSection();
      case CVSection.projects:
        return const ProjectsSection();
      case CVSection.preview:
        return const CVPreviewSection();
    }
  }

  Widget? _buildMobileNavigation(
    BuildContext context,
    CVSection currentSection,
  ) {
    const sections = CVSection.values;
    final currentIndex = sections.indexOf(currentSection);
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.colors;

    return SafeArea(
      child: Container(
        height: 70, // Fixed compact height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.white,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
        ),
        child: Row(
          children: [
            // Previous Button - Compact for mobile
            SizedBox(
              width: 70,
              height: 40,
              child: OutlinedButton(
                onPressed: currentIndex > 0
                    ? () {
                        ref.read(currentSectionProvider.notifier).state =
                            sections[currentIndex - 1];
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.caretLeft(), size: 14),
                      const SizedBox(width: 2),
                      Text(l10n.prev, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Section Indicator - Expanded to take remaining space
            Expanded(
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${currentIndex + 1} / ${sections.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Next Button - Compact for mobile
            SizedBox(
              width: 70,
              height: 40,
              child: ElevatedButton(
                onPressed: currentIndex < sections.length - 1
                    ? () {
                        ref.read(currentSectionProvider.notifier).state =
                            sections[currentIndex + 1];
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.next, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 2),
                      Icon(PhosphorIcons.caretRight(), size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.help),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.helpDescription,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(l10n.helpStep1),
            Text(l10n.helpStep2),
            Text(l10n.helpStep3),
            Text(l10n.helpStep4),
            Text(l10n.helpStep5),
            Text(l10n.helpStep6),
            Text(l10n.helpStep7),
            Text(l10n.helpStep8),
            Text(l10n.helpStep9),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              l10n.helpTip,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.palette(),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(l10n.selectTheme),
          ],
        ),
        content: const ThemeSelector(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
