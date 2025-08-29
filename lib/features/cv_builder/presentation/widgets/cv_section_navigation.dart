import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/theme_data.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/cv_provider.dart';

/// Navigation widget for CV sections
class CVSectionNavigation extends ConsumerWidget {
  final CVSection currentSection;
  final Function(CVSection) onSectionChanged;

  const CVSectionNavigation({
    super.key,
    required this.currentSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.colors;
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        Text(
          l10n.cvSections,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ...CVSection.values.map((section) {
          final isActive = section == currentSection;
          final isCompleted = _isSectionCompleted(section, ref);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
            child: _buildSectionTile(
              context,
              section,
              isActive,
              isCompleted,
              colors,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTile(
    BuildContext context,
    CVSection section,
    bool isActive,
    bool isCompleted,
    AppColorScheme colors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String title;
    String description;

    switch (section) {
      case CVSection.personalInfo:
        title = l10n.personalInformation;
        description = l10n.enterBasicContactInfo;
        break;
      case CVSection.summary:
        title = l10n.professionalSummary;
        description = l10n.summaryDescription;
        break;
      case CVSection.workExperience:
        title = l10n.workExperience;
        description = l10n.workExperienceDescription;
        break;
      case CVSection.education:
        title = l10n.education;
        description = l10n.educationDescription;
        break;
      case CVSection.skills:
        title = l10n.skills;
        description = l10n.skillsDescription;
        break;
      case CVSection.languages:
        title = l10n.languages;
        description = l10n.languagesDescription;
        break;
      case CVSection.certificates:
        title = l10n.certificates;
        description = l10n.certificatesDescription;
        break;
      case CVSection.projects:
        title = l10n.projects;
        description = l10n.projectsDescription;
        break;
      case CVSection.preview:
        title = l10n.cvPreview;
        description = l10n.previewDescription;
        break;
    }
    return Material(
      color: isActive ? colors.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: InkWell(
        onTap: () => onSectionChanged(section),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            border: isActive
                ? Border.all(color: colors.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              // Section Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? colors.primary
                      : isCompleted
                      ? colors.success
                      : colors.grey300,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  _getSectionIcon(section),
                  color: isActive || isCompleted
                      ? colors.white
                      : colors.grey600,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              // Section Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive ? colors.primary : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Completion Indicator
              if (isCompleted && !isActive)
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: colors.success,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  PhosphorIconData _getSectionIcon(CVSection section) {
    switch (section) {
      case CVSection.personalInfo:
        return PhosphorIcons.user();
      case CVSection.summary:
        return PhosphorIcons.article();
      case CVSection.workExperience:
        return PhosphorIcons.briefcase();
      case CVSection.education:
        return PhosphorIcons.graduationCap();
      case CVSection.skills:
        return PhosphorIcons.star();
      case CVSection.languages:
        return PhosphorIcons.translate();
      case CVSection.certificates:
        return PhosphorIcons.certificate();
      case CVSection.projects:
        return PhosphorIcons.codeBlock();
      case CVSection.preview:
        return PhosphorIcons.eye();
    }
  }

  bool _isSectionCompleted(CVSection section, WidgetRef ref) {
    final cvData = ref.read(cvDataProvider);

    switch (section) {
      case CVSection.personalInfo:
        return cvData.personalInfo.firstName.isNotEmpty &&
            cvData.personalInfo.lastName.isNotEmpty &&
            cvData.personalInfo.email.isNotEmpty &&
            cvData.personalInfo.phone.isNotEmpty;

      case CVSection.summary:
        return cvData.summary != null && cvData.summary!.isNotEmpty;

      case CVSection.workExperience:
        return cvData.workExperiences.isNotEmpty;

      case CVSection.education:
        return cvData.educations.isNotEmpty;

      case CVSection.skills:
        return cvData.skills.isNotEmpty;

      case CVSection.languages:
        return cvData.languages.isNotEmpty;

      case CVSection.certificates:
        return true; // Optional section

      case CVSection.projects:
        return true; // Optional section

      case CVSection.preview:
        return _isSectionCompleted(CVSection.personalInfo, ref) &&
            _isSectionCompleted(CVSection.summary, ref);
    }
  }
}
