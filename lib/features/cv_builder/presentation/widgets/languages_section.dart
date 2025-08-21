import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Languages section widget
class LanguagesSection extends ConsumerStatefulWidget {
  const LanguagesSection({super.key});

  @override
  ConsumerState<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends ConsumerState<LanguagesSection> {
  final _formKey = GlobalKey<FormState>();
  final _languageNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  LanguageLevel _selectedLevel = LanguageLevel.intermediate;
  Language? _editingLanguage;

  @override
  void dispose() {
    _languageNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _languageNameController.clear();
    _descriptionController.clear();
    _selectedLevel = LanguageLevel.intermediate;
    _editingLanguage = null;
  }

  void _editLanguage(Language language) {
    setState(() {
      _editingLanguage = language;
      _languageNameController.text = language.name;
      _selectedLevel = language.level;
      _descriptionController.clear(); // Languages don't have description in model
    });
  }

  void _deleteLanguage(String id) {
    ref.read(cvDataProvider.notifier).removeLanguage(id);
    if (_editingLanguage?.id == id) {
      _resetForm();
    }
  }

  void _saveLanguage() {
    if (!_formKey.currentState!.validate()) return;

    final language = Language(
      id: _editingLanguage?.id,
      name: _languageNameController.text.trim(),
      level: _selectedLevel,
    );

    if (_editingLanguage != null) {
      ref.read(cvDataProvider.notifier).updateLanguage(language);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language updated successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      ref.read(cvDataProvider.notifier).addLanguage(language);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Language added successfully!'), backgroundColor: AppColors.success));
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(cvDataProvider).languages;

    return ResponsiveCard(
      title: 'Languages',
      subtitle: 'Add languages you speak',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Edit Language Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingLanguage != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingLanguage != null ? AppColors.primary : AppColors.border,
                width: _editingLanguage != null ? 2 : 1,
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
                          if (_editingLanguage != null) ...[
                            Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary, size: 20),
                            const SizedBox(width: AppConstants.spacingS),
                          ],
                          Text(
                            _editingLanguage != null ? 'Edit Language' : 'Add New Language',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ],
                      ),
                      if (_editingLanguage != null)
                        TextButton.icon(
                          onPressed: _resetForm,
                          icon: Icon(PhosphorIcons.x()),
                          label: const Text('Cancel'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Language Name and Level
                  ResponsiveGrid(
                    children: [
                      ResponsiveFormField(
                        label: 'Language Name',
                        isRequired: true,
                        child: CustomTextFormField(
                          controller: _languageNameController,
                          hint: 'e.g., English, Spanish, French',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Language name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      ResponsiveFormField(
                        label: 'Proficiency Level',
                        isRequired: true,
                        child: DropdownButtonFormField<LanguageLevel>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: LanguageLevel.values.map((level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: _getLevelColor(level), shape: BoxShape.circle),
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
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveLanguage,
                      icon: Icon(_editingLanguage != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                      label: Text(_editingLanguage != null ? 'Update Language' : 'Add Language'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                        backgroundColor: _editingLanguage != null ? AppColors.success : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Languages List
          if (languages.isNotEmpty) ...[
            Text(
              'Your Languages (${languages.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...languages.map(_buildLanguageCard),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.translate(), size: 64, color: AppColors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No languages added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Add your first language above',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageCard(Language language) {
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
                        language.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: _getLevelColor(language.level), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            language.level.displayName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                      onPressed: () => _editLanguage(language),
                      icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteLanguage(language.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            LinearProgressIndicator(
              value: _getLevelPercentage(language.level),
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(language.level)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(LanguageLevel level) {
    switch (level) {
      case LanguageLevel.beginner:
        return AppColors.error;
      case LanguageLevel.elementary:
        return AppColors.warning;
      case LanguageLevel.intermediate:
        return AppColors.info;
      case LanguageLevel.upperIntermediate:
        return AppColors.primary;
      case LanguageLevel.advanced:
        return AppColors.success;
      case LanguageLevel.native:
        return AppColors.success;
    }
  }

  double _getLevelPercentage(LanguageLevel level) {
    switch (level) {
      case LanguageLevel.beginner:
        return 0.17; // A1
      case LanguageLevel.elementary:
        return 0.33; // A2
      case LanguageLevel.intermediate:
        return 0.50; // B1
      case LanguageLevel.upperIntermediate:
        return 0.67; // B2
      case LanguageLevel.advanced:
        return 0.83; // C1
      case LanguageLevel.native:
        return 1; // C2
    }
  }
}
