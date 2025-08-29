import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartDate), backgroundColor: AppColors.warning));
      return;
    }
    _showDateSelector(context, false);
  }

  void _saveEducation() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartDate), backgroundColor: AppColors.error));
      return;
    }

    if (!_isCurrentlyStudying && _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectEndDateOrMarkCurrent), backgroundColor: AppColors.error));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.educationUpdatedSuccessfully), backgroundColor: AppColors.success));
    } else {
      ref.read(cvDataProvider.notifier).addEducation(education);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.educationAddedSuccessfully), backgroundColor: AppColors.success));
    }

    _resetForm();
  }

  void _updateEducation() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartDate), backgroundColor: AppColors.error));
      return;
    }

    if (!_isCurrentlyStudying && _endDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectEndDateOrMarkCurrent), backgroundColor: AppColors.error));
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.educationUpdatedSuccessfully), backgroundColor: AppColors.success));

    _resetForm();
  }

  void _showDateSelector(BuildContext context, bool isStartDate) {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1949, (index) => currentYear - index);
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];

    int selectedYear = isStartDate ? (_startDate?.year ?? currentYear) : (_endDate?.year ?? currentYear);
    int selectedMonth = isStartDate ? (_startDate?.month ?? 1) : (_endDate?.month ?? 1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isStartDate ? l10n.selectStartDate : l10n.selectEndDate),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year dropdown
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: InputDecoration(labelText: l10n.year, border: const OutlineInputBorder()),
                items: years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
                onChanged: (year) {
                  if (year != null) selectedYear = year;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Month dropdown
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: InputDecoration(labelText: l10n.month, border: const OutlineInputBorder()),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
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
            child: Text(l10n.select),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final educations = ref.watch(cvDataProvider).educations;

    return ResponsiveCard(
      title: l10n.education,
      subtitle: l10n.educationDescription,
      actions: educations.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), color: Colors.red, size: 18),
                tooltip: l10n.clearAllEducation,
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
                              _editingEducation != null ? l10n.editEducation : l10n.addNewEducation,
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
                            label: Text(l10n.cancel),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Degree and Institution
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: l10n.degreeCertificate,
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _degreeController,
                            focusNode: _degreeFocusNode,
                            hint: l10n.degreeHint,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.degreeRequired;
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
                          label: l10n.institution,
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _institutionController,
                            focusNode: _institutionFocusNode,
                            hint: l10n.institutionHint,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.institutionRequired;
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
                          label: l10n.location,
                          child: CustomTextFormField(
                            controller: _locationController,
                            focusNode: _locationFocusNode,
                            hint: l10n.locationHint,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _gpaFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: l10n.gpaOptional,
                          child: CustomTextFormField(
                            controller: _gpaController,
                            focusNode: _gpaFocusNode,
                            hint: l10n.gpaHint,
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
                          label: l10n.startDate,
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
                          label: l10n.endDate,
                          child: _isCurrentlyStudying
                              ? CustomTextFormField(
                                  controller: _endDateController,
                                  hint: AppLocalizations.of(context)!.currentlyWorking,
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
                        Text(AppLocalizations.of(context)!.currentlyWorking),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Description
                    ResponsiveFormField(
                      label: l10n.description,
                      child: CustomTextFormField(
                        controller: _descriptionController,
                        hint: l10n.descriptionHint,
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
                        label: Text(_editingEducation != null ? l10n.editEducation : l10n.addEducation),
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
              '${l10n.education} (${educations.length})',
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
                    l10n.educationDescription,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    l10n.getStarted,
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
                      tooltip: AppLocalizations.of(context)!.edit,
                    ),
                    IconButton(
                      onPressed: () => _deleteEducation(education.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: AppLocalizations.of(context)!.delete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '${education.startDate.year}-${education.startDate.month.toString().padLeft(2, '0')} - ${education.endDate != null ? '${education.endDate!.year}-${education.endDate!.month.toString().padLeft(2, '0')}' : AppLocalizations.of(context)!.currentlyWorking}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppConstants.spacingM),
            if (education.description != null && education.description!.isNotEmpty)
              Text(education.description!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
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
              Text(AppLocalizations.of(context)!.clearAllEducation),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.clearEducationConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearEducations();
                Navigator.of(context).pop();
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.educationCleared),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(AppLocalizations.of(context)!.clear),
            ),
          ],
        );
      },
    );
  }
}
