import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
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
        const SnackBar(
          content: Text('Skill updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ref.read(cvDataProvider.notifier).addSkill(skill);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(cvDataProvider).skills;

    return ResponsiveCard(
      title: 'Skills',
      subtitle: 'Highlight your technical and soft skills',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Edit Skill Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingSkill != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingSkill != null
                    ? AppColors.primary
                    : AppColors.border,
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
                            Icon(
                              PhosphorIcons.pencilSimple(),
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.spacingS),
                          ],
                          Text(
                            _editingSkill != null
                                ? 'Edit Skill'
                                : 'Add New Skill',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      if (_editingSkill != null)
                        TextButton.icon(
                          onPressed: _resetForm,
                          icon: Icon(PhosphorIcons.x()),
                          label: const Text('Cancel'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Skill Name
                  ResponsiveFormField(
                    label: 'Skill Name',
                    isRequired: true,
                    child: CustomTextFormField(
                      controller: _skillNameController,
                      hint: 'e.g., Flutter, Project Management, English',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Skill name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Skill Level and Category
                  ResponsiveGrid(
                    children: [
                      ResponsiveFormField(
                        label: 'Skill Level',
                        isRequired: true,
                        child: DropdownButtonFormField<SkillLevel>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: SkillLevel.values.map((level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(level),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(level.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedLevel = value;
                              });
                            }
                          },
                        ),
                      ),
                      ResponsiveFormField(
                        label: 'Category',
                        isRequired: true,
                        child: DropdownButtonFormField<SkillCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: SkillCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSkill,
                      icon: Icon(
                        _editingSkill != null
                            ? PhosphorIcons.check()
                            : PhosphorIcons.plus(),
                      ),
                      label: Text(
                        _editingSkill != null ? 'Update Skill' : 'Add Skill',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingM,
                        ),
                        backgroundColor: _editingSkill != null
                            ? AppColors.success
                            : null,
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
            Text(
              'Your Skills (${skills.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...skills.map(_buildSkillCard),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.lightning(),
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No skills added yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Add your first skill above',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getLevelColor(skill.level),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${skill.level.displayName} • ${skill.category.displayName}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editSkill(skill),
                      icon: Icon(
                        PhosphorIcons.pencilSimple(),
                        color: AppColors.primary,
                      ),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteSkill(skill.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            LinearProgressIndicator(
              value: skill.level.percentage / 100,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLevelColor(skill.level),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return AppColors.warning;
      case SkillLevel.intermediate:
        return AppColors.info;
      case SkillLevel.advanced:
        return AppColors.primary;
      case SkillLevel.expert:
        return AppColors.success;
    }
  }
}
