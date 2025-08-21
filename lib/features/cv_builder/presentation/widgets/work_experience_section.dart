import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Work experience section widget
class WorkExperienceSection extends ConsumerStatefulWidget {
  const WorkExperienceSection({super.key});

  @override
  ConsumerState<WorkExperienceSection> createState() => _WorkExperienceSectionState();
}

class _WorkExperienceSectionState extends ConsumerState<WorkExperienceSection> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Focus nodes for proper tab navigation
  final _companyFocusNode = FocusNode();
  final _positionFocusNode = FocusNode();
  final _startDateFocusNode = FocusNode();
  final _endDateFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  bool _isCurrentlyWorking = false;
  WorkExperience? _editingExperience;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();

    // Dispose focus nodes
    _companyFocusNode.dispose();
    _positionFocusNode.dispose();
    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _companyController.clear();
    _positionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
    _isCurrentlyWorking = false;
    _startDate = null;
    _endDate = null;
    _editingExperience = null;
  }

  void _editExperience(WorkExperience experience) {
    setState(() {
      _editingExperience = experience;
      _companyController.text = experience.company;
      _positionController.text = experience.jobTitle;
      _startDateController.text =
          '${experience.startDate.year.toString().padLeft(4, '0')}-${experience.startDate.month.toString().padLeft(2, '0')}';
      _endDateController.text = experience.endDate != null
          ? '${experience.endDate!.year.toString().padLeft(4, '0')}-${experience.endDate!.month.toString().padLeft(2, '0')}'
          : '';
      _descriptionController.text = experience.description ?? '';
      _isCurrentlyWorking = experience.isCurrentJob;
      _startDate = experience.startDate;
      _endDate = experience.endDate;
    });
  }

  void _deleteExperience(String id) {
    ref.read(cvDataProvider.notifier).removeWorkExperience(id);
    if (_editingExperience?.id == id) {
      _resetForm();
    }
  }

  void _selectStartDate() {
    _showDateSelector(context, true);
  }

  void _selectEndDate() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first'), backgroundColor: AppColors.warning),
      );
      return;
    }
    _showDateSelector(context, false);
  }

  void _showDateSelector(BuildContext context, bool isStartDate) {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1949, (index) => currentYear - index);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    int selectedYear = isStartDate ? (_startDate?.year ?? currentYear) : (_endDate?.year ?? currentYear);
    int selectedMonth = isStartDate ? (_startDate?.month ?? 1) : (_endDate?.month ?? 1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isStartDate ? 'Select Start Date' : 'Select End Date'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year dropdown
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                items: years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
                onChanged: (year) {
                  if (year != null) selectedYear = year;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Month dropdown
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
                items: months
                    .asMap()
                    .entries
                    .map((entry) => DropdownMenuItem(value: entry.key + 1, child: Text(entry.value)))
                    .toList(),
                onChanged: (month) {
                  if (month != null) selectedMonth = month;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final selectedDate = DateTime(selectedYear, selectedMonth, 1);

              if (isStartDate) {
                setState(() {
                  _startDate = selectedDate;
                  _startDateController.text =
                      '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}';
                });
              } else {
                setState(() {
                  _endDate = selectedDate;
                  _endDateController.text =
                      '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}';
                });
              }

              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _saveExperience() {
    if (_formKey.currentState?.validate() ?? false) {
      if (kDebugMode) print('DEBUG SAVE: Company Controller: ${_companyController.text}');
      if (kDebugMode) print('DEBUG SAVE: Position Controller: ${_positionController.text}');

      final experience = WorkExperience(
        id: const Uuid().v4(),
        company: _companyController.text,
        jobTitle: _positionController.text,
        startDate: _startDate!,
        endDate: _isCurrentlyWorking ? null : _endDate,
        isCurrentJob: _isCurrentlyWorking,
        description: _descriptionController.text,
      );

      if (kDebugMode) {
        print('DEBUG SAVE: Created Experience - Company: ${experience.company}, JobTitle: ${experience.jobTitle}');
      }

      ref.read(cvDataProvider.notifier).addWorkExperience(experience);
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experience added successfully!'), backgroundColor: AppColors.success),
      );
    }
  }

  void _updateExperience() {
    if (_formKey.currentState?.validate() ?? false) {
      if (kDebugMode) print('DEBUG: Company Controller: ${_companyController.text}');
      if (kDebugMode) print('DEBUG: Position Controller: ${_positionController.text}');

      final experience = WorkExperience(
        id: _editingExperience!.id,
        company: _companyController.text,
        jobTitle: _positionController.text,
        startDate: _startDate!,
        endDate: _isCurrentlyWorking ? null : _endDate,
        isCurrentJob: _isCurrentlyWorking,
        description: _descriptionController.text,
      );

      if (kDebugMode) {
        print('DEBUG: Created Experience - Company: ${experience.company}, JobTitle: ${experience.jobTitle}');
      }

      ref.read(cvDataProvider.notifier).updateWorkExperience(experience);
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experience updated successfully!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workExperiences = ref.watch(cvDataProvider).workExperiences;

    return ResponsiveCard(
      title: 'Work Experience',
      subtitle: 'Add your professional work experience',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Edit Experience Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingExperience != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingExperience != null ? AppColors.primary : AppColors.border,
                width: _editingExperience != null ? 2 : 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: FocusTraversalGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_editingExperience != null) ...[
                              Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary, size: 20),
                              const SizedBox(width: AppConstants.spacingS),
                            ],
                            Text(
                              _editingExperience != null ? 'Edit Experience' : 'Add New Experience',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                        if (_editingExperience != null)
                          TextButton.icon(
                            onPressed: _resetForm,
                            icon: Icon(PhosphorIcons.x()),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Company and Position
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Company Name',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _companyController,
                            focusNode: _companyFocusNode,
                            hint: 'e.g., Google, Microsoft',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Company name is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _positionFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'Job Position',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _positionController,
                            focusNode: _positionFocusNode,
                            hint: 'e.g., Senior Developer, Project Manager',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Job position is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _startDateFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Dates
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Start Date',
                          isRequired: true,
                          child: GestureDetector(
                            onTap: _selectStartDate,
                            child: CustomTextFormField(
                              controller: _startDateController,
                              focusNode: _startDateFocusNode,
                              hint: 'YYYY-MM',
                              enabled: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Start date is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'End Date',
                          child: _isCurrentlyWorking
                              ? CustomTextFormField(
                                  controller: _endDateController,
                                  focusNode: _endDateFocusNode,
                                  hint: 'Present',
                                  enabled: false,
                                )
                              : GestureDetector(
                                  onTap: _selectEndDate,
                                  child: CustomTextFormField(
                                    controller: _endDateController,
                                    focusNode: _endDateFocusNode,
                                    hint: 'YYYY-MM',
                                    enabled: false,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Currently working checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isCurrentlyWorking,
                          onChanged: (value) {
                            setState(() {
                              _isCurrentlyWorking = value ?? false;
                              if (_isCurrentlyWorking) {
                                _endDateController.clear();
                                _endDate = null;
                              }
                            });
                          },
                        ),
                        const Text('I currently work here'),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Description
                    ResponsiveFormField(
                      label: 'Job Description',
                      isRequired: true,
                      child: CustomTextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        hint: 'Describe your responsibilities, achievements, and key contributions...',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Job description is required';
                          }
                          if (value.length < 50) {
                            return 'Description should be at least 50 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _editingExperience != null ? _updateExperience : _saveExperience,
                        icon: Icon(_editingExperience != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                        label: Text(_editingExperience != null ? 'Update Experience' : 'Add Experience'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                          backgroundColor: _editingExperience != null ? AppColors.success : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Experience List
          if (workExperiences.isNotEmpty) ...[
            Text(
              'Your Experience (${workExperiences.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...workExperiences.map(_buildExperienceCard),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.briefcase(), size: 64, color: AppColors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No work experience added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Add your first work experience above',
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

  Widget _buildExperienceCard(WorkExperience experience) {
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
                        experience.jobTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        experience.company,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editExperience(experience),
                      icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteExperience(experience.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '${experience.startDate.year}-${experience.startDate.month.toString().padLeft(2, '0')} - ${experience.endDate != null ? '${experience.endDate!.year}-${experience.endDate!.month.toString().padLeft(2, '0')}' : 'Present'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(experience.description ?? 'No description provided', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
