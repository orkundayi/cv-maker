import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cv_provider.dart';

/// Navigation widget for CV sections
class CVSectionNavigation extends ConsumerWidget {
  final CVSection currentSection;
  final Function(CVSection) onSectionChanged;

  const CVSectionNavigation({super.key, required this.currentSection, required this.onSectionChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        Text(
          'CV Sections',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ...CVSection.values.map((section) {
          final isActive = section == currentSection;
          final isCompleted = _isSectionCompleted(section, ref);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
            child: _buildSectionTile(context, section, isActive, isCompleted),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTile(BuildContext context, CVSection section, bool isActive, bool isCompleted) {
    return Material(
      color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: InkWell(
        onTap: () => onSectionChanged(section),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
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
                      ? AppColors.primary
                      : isCompleted
                      ? AppColors.success
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  _getSectionIcon(section),
                  color: isActive || isCompleted ? AppColors.white : AppColors.grey600,
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
                      section.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      section.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Completion Indicator
              if (isCompleted && !isActive)
                Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.success, size: 20),
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
        return _isSectionCompleted(CVSection.personalInfo, ref) && _isSectionCompleted(CVSection.summary, ref);
    }
  }
}
