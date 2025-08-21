import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
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

    return Scaffold(
      appBar: _buildAppBar(context),
      body: ResponsiveUtils.isMobile(context)
          ? _buildMobileLayout(context, ref, currentSection)
          : _buildDesktopLayout(context, ref, currentSection),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? _buildMobileNavigation(context, ref, currentSection)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(PhosphorIcons.fileText(), color: AppColors.primary, size: 28),
          const SizedBox(width: AppConstants.spacingM),
          Text(
            AppConstants.appName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        if (!ResponsiveUtils.isMobile(context)) ...[
          IconButton(onPressed: () => _showHelpDialog(context), icon: Icon(PhosphorIcons.question()), tooltip: 'Help'),
          const SizedBox(width: AppConstants.spacingS),
        ],
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, CVSection currentSection) {
    return ResponsiveLayout(child: _buildCurrentSection(context, ref, currentSection));
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, CVSection currentSection) {
    return Row(
      children: [
        // Left Navigation Panel
        Container(
          width: 300,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border(right: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: CVSectionNavigation(
            currentSection: currentSection,
            onSectionChanged: (section) {
              ref.read(currentSectionProvider.notifier).state = section;
            },
          ),
        ),
        // Main Content Area
        Expanded(child: ResponsiveLayout(child: _buildCurrentSection(context, ref, currentSection))),
      ],
    );
  }

  Widget _buildCurrentSection(BuildContext context, WidgetRef ref, CVSection currentSection) {
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

  Widget? _buildMobileNavigation(BuildContext context, WidgetRef ref, CVSection currentSection) {
    const sections = CVSection.values;
    final currentIndex = sections.indexOf(currentSection);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: currentIndex > 0
                  ? () {
                      ref.read(currentSectionProvider.notifier).state = sections[currentIndex - 1];
                    }
                  : null,
              icon: Icon(PhosphorIcons.caretLeft()),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Section Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Text(
              '${currentIndex + 1} / ${sections.length}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Next Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentIndex < sections.length - 1
                  ? () {
                      ref.read(currentSectionProvider.notifier).state = sections[currentIndex + 1];
                    }
                  : null,
              icon: Icon(PhosphorIcons.caretRight()),
              label: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CV Builder Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to CV Maker! Follow these steps to create your professional resume:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: AppConstants.spacingM),
            Text('1. Enter your personal information'),
            Text('2. Write a professional summary'),
            Text('3. Add your work experiences'),
            Text('4. List your education'),
            Text('5. Highlight your skills'),
            Text('6. Add languages you speak'),
            Text('7. Include certifications'),
            Text('8. Showcase your projects'),
            Text('9. Preview and export your CV'),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'Tip: All fields are automatically saved as you type!',
              style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primary),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it!'))],
      ),
    );
  }
}
