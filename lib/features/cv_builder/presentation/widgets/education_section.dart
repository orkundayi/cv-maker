import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Education section widget
class EducationSection extends ConsumerStatefulWidget {
  const EducationSection({super.key});

  @override
  ConsumerState<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends ConsumerState<EducationSection> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _degreeController;
  late final TextEditingController _institutionController;
  late final TextEditingController _locationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gpaController;

  // Focus nodes for proper tab navigation
  late final FocusNode _degreeFocusNode;
  late final FocusNode _institutionFocusNode;
  late final FocusNode _locationFocusNode;
  late final FocusNode _startDateFocusNode;
  late final FocusNode _endDateFocusNode;
  late final FocusNode _descriptionFocusNode;
  late final FocusNode _gpaFocusNode;

  // Form state
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyStudying = false;
  Education? _editingEducation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _degreeController = TextEditingController();
    _institutionController = TextEditingController();
    _locationController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _descriptionController = TextEditingController();
    _gpaController = TextEditingController();

    // Initialize focus nodes
    _degreeFocusNode = FocusNode();
    _institutionFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _startDateFocusNode = FocusNode();
    _endDateFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _gpaFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _gpaController.dispose();

    // Dispose focus nodes
    _degreeFocusNode.dispose();
    _institutionFocusNode.dispose();
    _locationFocusNode.dispose();
    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _gpaFocusNode.dispose();

    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _degreeController.clear();
    _institutionController.clear();
    _locationController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
    _gpaController.clear();
    _startDate = null;
    _endDate = null;
    _isCurrentlyStudying = false;
    _editingEducation = null;
  }

  void _editEducation(Education education) {
    setState(() {
      _editingEducation = education;
      _degreeController.text = education.degree;
      _institutionController.text = education.institution;
      _locationController.text = education.location ?? '';
      _startDate = education.startDate;
      _startDateController.text =
          '${education.startDate.year.toString().padLeft(4, '0')}-${education.startDate.month.toString().padLeft(2, '0')}';
      _endDate = education.endDate;
      _endDateController.text = education.endDate != null
          ? '${education.endDate!.year.toString().padLeft(4, '0')}-${education.endDate!.month.toString().padLeft(2, '0')}'
          : '';
      _descriptionController.text = education.description ?? '';
      _gpaController.text = education.gpa?.toString() ?? '';
      _isCurrentlyStudying = education.isCurrentStudy;
    });
  }

  void _deleteEducation(String id) {
    ref.read(cvDataProvider.notifier).removeEducation(id);
    if (_editingEducation?.id == id) {
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

  void _saveEducation() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a start date'), backgroundColor: AppColors.error));
      return;
    }

    if (!_isCurrentlyStudying && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an end date or mark as current study'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final education = Education(
      id: _editingEducation?.id,
      degree: _degreeController.text.trim(),
      institution: _institutionController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      startDate: _startDate!,
      endDate: _isCurrentlyStudying ? null : _endDate,
      isCurrentStudy: _isCurrentlyStudying,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      gpa: _gpaController.text.trim().isEmpty ? null : double.tryParse(_gpaController.text.trim()),
    );

    if (_editingEducation != null) {
      ref.read(cvDataProvider.notifier).updateEducation(education);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education updated successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      ref.read(cvDataProvider.notifier).addEducation(education);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education added successfully!'), backgroundColor: AppColors.success),
      );
    }

    _resetForm();
  }

  void _updateEducation() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a start date'), backgroundColor: AppColors.error));
      return;
    }

    if (!_isCurrentlyStudying && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an end date or mark as current study'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final education = Education(
      id: _editingEducation!.id,
      degree: _degreeController.text.trim(),
      institution: _institutionController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      startDate: _startDate!,
      endDate: _isCurrentlyStudying ? null : _endDate,
      isCurrentStudy: _isCurrentlyStudying,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      gpa: _gpaController.text.trim().isEmpty ? null : double.tryParse(_gpaController.text.trim()),
    );

    ref.read(cvDataProvider.notifier).updateEducation(education);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Education updated successfully!'), backgroundColor: AppColors.success),
    );

    _resetForm();
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

  @override
  Widget build(BuildContext context) {
    final educations = ref.watch(cvDataProvider).educations;

    return ResponsiveCard(
      title: 'Education',
      subtitle: 'Add your educational background',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Edit Education Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingEducation != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingEducation != null ? AppColors.primary : AppColors.border,
                width: _editingEducation != null ? 2 : 1,
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
                            if (_editingEducation != null) ...[
                              Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary, size: 20),
                              const SizedBox(width: AppConstants.spacingS),
                            ],
                            Text(
                              _editingEducation != null ? 'Edit Education' : 'Add New Education',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                        if (_editingEducation != null)
                          TextButton.icon(
                            onPressed: _resetForm,
                            icon: Icon(PhosphorIcons.x()),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Degree and Institution
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Degree/Certificate',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _degreeController,
                            focusNode: _degreeFocusNode,
                            hint: 'e.g., Bachelor of Science in Computer Science',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Degree is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _institutionFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'Institution',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _institutionController,
                            focusNode: _institutionFocusNode,
                            hint: 'e.g., University of Technology',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Institution is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _locationFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Location and GPA
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Location',
                          child: CustomTextFormField(
                            controller: _locationController,
                            focusNode: _locationFocusNode,
                            hint: 'e.g., New York, USA',
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _gpaFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'GPA (Optional)',
                          child: CustomTextFormField(
                            controller: _gpaController,
                            focusNode: _gpaFocusNode,
                            hint: 'e.g., 3.8',
                            keyboardType: TextInputType.number,
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

                    // Start Date and End Date
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Start Date',
                          isRequired: true,
                          child: GestureDetector(
                            onTap: _selectStartDate,
                            child: CustomTextFormField(
                              controller: _startDateController,
                              hint: 'YYYY-MM',
                              enabled: false,
                            ),
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'End Date',
                          child: _isCurrentlyStudying
                              ? CustomTextFormField(
                                  controller: _endDateController,
                                  hint: 'Currently studying',
                                  enabled: false,
                                )
                              : GestureDetector(
                                  onTap: _selectEndDate,
                                  child: CustomTextFormField(
                                    controller: _endDateController,
                                    hint: 'YYYY-MM',
                                    enabled: false,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Currently Studying Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isCurrentlyStudying,
                          onChanged: (value) {
                            setState(() {
                              _isCurrentlyStudying = value ?? false;
                              if (_isCurrentlyStudying) {
                                _endDateController.clear();
                                _endDate = null;
                              }
                            });
                          },
                        ),
                        const Text('I am currently studying here'),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Description
                    ResponsiveFormField(
                      label: 'Description (Optional)',
                      child: CustomTextFormField(
                        controller: _descriptionController,
                        hint: 'Describe your studies, achievements, or relevant coursework...',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _editingEducation != null ? _updateEducation : _saveEducation,
                        icon: Icon(_editingEducation != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                        label: Text(_editingEducation != null ? 'Update Education' : 'Add Education'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                          backgroundColor: _editingEducation != null ? AppColors.success : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Education List
          if (educations.isNotEmpty) ...[
            Text(
              'Your Education (${educations.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...educations.map(_buildEducationCard),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.graduationCap(), size: 64, color: AppColors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No education added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Add your first education entry above',
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

  Widget _buildEducationCard(Education education) {
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
                        education.degree,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        education.institution,
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
                      onPressed: () => _editEducation(education),
                      icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteEducation(education.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '${education.startDate.year}-${education.startDate.month.toString().padLeft(2, '0')} - ${education.endDate != null ? '${education.endDate!.year}-${education.endDate!.month.toString().padLeft(2, '0')}' : 'Present'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(education.description ?? 'No description provided', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
