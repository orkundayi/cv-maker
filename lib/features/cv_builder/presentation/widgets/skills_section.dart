import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Skills section widget
class SkillsSection extends ConsumerStatefulWidget {
  const SkillsSection({super.key});

  @override
  ConsumerState<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends ConsumerState<SkillsSection> {
  final _formKey = GlobalKey<FormState>();
  final _skillNameController = TextEditingController();
  SkillLevel _selectedLevel = SkillLevel.intermediate;
  SkillCategory _selectedCategory = SkillCategory.technical;
  Skill? _editingSkill;

  @override
  void dispose() {
    _skillNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _skillNameController.clear();
    _selectedLevel = SkillLevel.intermediate;
    _selectedCategory = SkillCategory.technical;
    _editingSkill = null;
  }

  void _editSkill(Skill skill) {
    setState(() {
      _editingSkill = skill;
      _skillNameController.text = skill.name;
      _selectedLevel = skill.level;
      _selectedCategory = skill.category;
    });
  }

  void _deleteSkill(String id) {
    ref.read(cvDataProvider.notifier).removeSkill(id);
    if (_editingSkill?.id == id) {
      _resetForm();
    }
  }

  void _saveSkill() {
    if (!_formKey.currentState!.validate()) return;

    final skill = Skill(
      id: _editingSkill?.id,
      name: _skillNameController.text.trim(),
      level: _selectedLevel,
      category: _selectedCategory,
    );

    if (_editingSkill != null) {
      ref.read(cvDataProvider.notifier).updateSkill(skill);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.educationUpdatedSuccessfully),
          backgroundColor: ref.colors.success,
        ),
      );
    } else {
      ref.read(cvDataProvider.notifier).addSkill(skill);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.educationAddedSuccessfully),
          backgroundColor: ref.colors.success,
        ),
      );
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skills = ref.watch(cvDataProvider).skills;
    final isMobile = ResponsiveUtils.isMobile(context);

    return ResponsiveCard(
      title: l10n.skillsExpertise,
      subtitle: l10n.skillsDescription,
      actions: skills.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), size: 18),
                tooltip: l10n.clearAllSkills,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Edit Skill Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingSkill != null
                  ? ref.colors.primary.withOpacity(0.05)
                  : ref.colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingSkill != null ? ref.colors.primary : ref.colors.border,
                width: _editingSkill != null ? 2 : 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_editingSkill != null) ...[
                            Icon(PhosphorIcons.pencilSimple(), color: ref.colors.primary, size: 20),
                            const SizedBox(width: AppConstants.spacingS),
                          ],
                          Text(
                            _editingSkill != null ? l10n.editSkill : l10n.addSkill,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: ref.colors.primary),
                          ),
                        ],
                      ),
                      if (_editingSkill != null)
                        TextButton.icon(
                          onPressed: _resetForm,
                          icon: Icon(PhosphorIcons.x()),
                          label: Text(l10n.cancel),
                          style: TextButton.styleFrom(foregroundColor: ref.colors.error),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Skill Name
                  ResponsiveFormField(
                    label: l10n.skillName,
                    isRequired: true,
                    child: CustomTextFormField(
                      controller: _skillNameController,
                      hint: l10n.skillNameHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.firstNameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Skill Level (Visual Selector)
                  ResponsiveFormField(
                    label: l10n.skillLevel,
                    isRequired: true,
                    child: Column(
                      children: [
                        Wrap(
                          spacing: isMobile ? 8 : 12,
                          runSpacing: 8,
                          children: SkillLevel.values.map((level) {
                            final isSelected = level == _selectedLevel;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedLevel = level),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: isMobile ? 8 : 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? _getLevelColor(level).withOpacity(0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? _getLevelColor(level) : Theme.of(context).dividerColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildLevelIndicator(level, isSelected),
                                    const SizedBox(width: 8),
                                    Text(
                                      _localizeSkillLevel(context, level),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isSelected
                                            ? _getLevelColor(level)
                                            : Theme.of(context).textTheme.bodyMedium?.color,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Category Selector (Visual)
                  ResponsiveFormField(
                    label: l10n.skillCategory,
                    isRequired: true,
                    child: Wrap(
                      spacing: isMobile ? 6 : 8,
                      runSpacing: 6,
                      children: SkillCategory.values.map((category) {
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _localizeSkillCategory(context, category),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).textTheme.bodySmall?.color,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSkill,
                      icon: Icon(_editingSkill != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                      label: Text(_editingSkill != null ? l10n.editSkill : l10n.addSkill),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                        backgroundColor: _editingSkill != null ? ref.colors.success : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Skills List
          if (skills.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.skills} (${skills.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${skills.length} ${AppLocalizations.of(context)!.skills.toLowerCase()}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            // Skills Grid for better organization
            _buildSkillsGrid(skills),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.lightning(), size: 64, color: ref.colors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    l10n.skillsDescription,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ref.colors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    l10n.getStarted,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ref.colors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return ref.colors.warning;
      case SkillLevel.intermediate:
        return ref.colors.info;
      case SkillLevel.advanced:
        return ref.colors.primary;
      case SkillLevel.expert:
        return ref.colors.success;
    }
  }

  Widget _buildLevelIndicator(SkillLevel level, bool isSelected) {
    final dots = _getLevelDots(level);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < dots
                ? (isSelected ? _getLevelColor(level) : Theme.of(context).primaryColor)
                : Theme.of(context).dividerColor,
          ),
        );
      }),
    );
  }

  int _getLevelDots(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 1;
      case SkillLevel.intermediate:
        return 3;
      case SkillLevel.advanced:
        return 4;
      case SkillLevel.expert:
        return 5;
    }
  }

  String _localizeSkillLevel(BuildContext context, SkillLevel level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case SkillLevel.beginner:
        return l10n.beginner;
      case SkillLevel.intermediate:
        return l10n.intermediate;
      case SkillLevel.advanced:
        return l10n.advanced;
      case SkillLevel.expert:
        return l10n.expert;
    }
  }

  String _localizeSkillCategory(BuildContext context, SkillCategory category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case SkillCategory.technical:
        return l10n.technical;
      case SkillCategory.soft:
        return l10n.soft;
      case SkillCategory.language:
        return l10n.languages;
      case SkillCategory.other:
        return l10n.other;
    }
  }

  IconData _getCategoryIcon(SkillCategory category) {
    switch (category) {
      case SkillCategory.technical:
        return PhosphorIcons.code();
      case SkillCategory.soft:
        return PhosphorIcons.users();
      case SkillCategory.language:
        return PhosphorIcons.translate();
      case SkillCategory.other:
        return PhosphorIcons.question();
    }
  }

  Widget _buildSkillsGrid(List<Skill> skills) {
    final isMobile = ResponsiveUtils.isMobile(context);

    // Group skills by category
    final groupedSkills = <SkillCategory, List<Skill>>{};
    for (final skill in skills) {
      groupedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }

    return Column(
      children: groupedSkills.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Row(
                children: [
                  Icon(_getCategoryIcon(entry.key), size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    entry.key.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.value.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingS),

              // Skills in this category
              if (isMobile)
                // Mobile: Single column
                Column(children: entry.value.map(_buildModernSkillCard).toList())
              else
                // Desktop: Grid layout
                Wrap(
                  spacing: AppConstants.spacingM,
                  runSpacing: AppConstants.spacingM,
                  children: entry.value
                      .map(
                        (skill) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 80) / 2 - AppConstants.spacingM,
                          child: _buildModernSkillCard(skill),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernSkillCard(Skill skill) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editSkill(skill),
                      icon: Icon(PhosphorIcons.pencilSimple(), size: 18),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      tooltip: AppLocalizations.of(context)!.edit,
                    ),
                    IconButton(
                      onPressed: () => _deleteSkill(skill.id),
                      icon: Icon(PhosphorIcons.trash(), size: 18, color: ref.colors.error),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      tooltip: AppLocalizations.of(context)!.delete,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingS),

            // Level indicator
            Row(
              children: [
                Text(
                  _localizeSkillLevel(context, skill.level),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _getLevelColor(skill.level), fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _getLevelPercentage(skill.level),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getLevelColor(skill.level),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_getLevelPercentage(skill.level) * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getLevelPercentage(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 0.25;
      case SkillLevel.intermediate:
        return 0.6;
      case SkillLevel.advanced:
        return 0.8;
      case SkillLevel.expert:
        return 1;
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(PhosphorIcons.warning(), color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.clearAllSkills),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.clearSkillsConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearSkills();
                Navigator.of(context).pop();
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.skillsCleared),
                    backgroundColor: ref.colors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(AppLocalizations.of(context)!.clearAllSkills),
            ),
          ],
        );
      },
    );
  }
}
