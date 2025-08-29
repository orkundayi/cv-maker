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
class CVBuilderPage extends ConsumerWidget {
  const CVBuilderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(currentSectionProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(context, ref, l10n),
      body: ResponsiveUtils.isMobile(context)
          ? _buildMobileLayout(context, ref, currentSection)
          : _buildDesktopLayout(context, ref, currentSection),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? _buildMobileNavigation(context, ref, currentSection)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final languageNotifier = ref.read(languageProvider.notifier);
    final currentLocale = ref.watch(languageProvider);
    final colors = ref.colors;

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
          onPressed: () => _showThemeSelector(context),
          icon: Icon(PhosphorIcons.palette(), color: colors.primary),
          tooltip: 'Tema Seç',
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

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    CVSection currentSection,
  ) {
    return ResponsiveLayout(
      child: _buildCurrentSection(context, ref, currentSection),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    CVSection currentSection,
  ) {
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
            child: _buildCurrentSection(context, ref, currentSection),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSection(
    BuildContext context,
    WidgetRef ref,
    CVSection currentSection,
  ) {
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
    WidgetRef ref,
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

  void _showThemeSelector(BuildContext context) {
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
            const Text('Tema Seç'),
          ],
        ),
        content: const ThemeSelector(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
