import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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
      title: 'Professional Experience',
      subtitle: 'Showcase your career journey and achievements',
      actions: workExperiences.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), color: Colors.red, size: 18),
                tooltip: 'Clear All Experiences',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Career Timeline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${workExperiences.length} positions',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),
            _buildExperienceTimeline(workExperiences),
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

  Widget _buildExperienceTimeline(List<WorkExperience> experiences) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        final isLast = index == experiences.length - 1;

        return _buildTimelineItem(experience, isLast, isMobile);
      },
    );
  }

  Widget _buildTimelineItem(WorkExperience experience, bool isLast, bool isMobile) {
    final duration = _calculateDuration(experience.startDate, experience.endDate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: experience.isCurrentJob ? Theme.of(context).primaryColor : AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: isMobile ? 80 : 100,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Experience card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : AppConstants.spacingL),
            padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience.jobTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            experience.company,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editExperience(experience),
                          icon: Icon(PhosphorIcons.pencilSimple(), size: 18),
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: () => _deleteExperience(experience.id),
                          icon: Icon(PhosphorIcons.trash(), size: 18, color: AppColors.error),
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingS),

                // Duration and location - responsive layout
                if (isMobile)
                  // Mobile: Stack vertically to save space
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date range
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: experience.isCurrentJob
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.calendar(),
                              size: 14,
                              color: experience.isCurrentJob ? Theme.of(context).primaryColor : AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _formatDateRange(experience.startDate, experience.endDate),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: experience.isCurrentJob ? Theme.of(context).primaryColor : AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Duration and location in a row with wrap
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Duration
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              duration,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),

                          // Location
                          if (experience.location != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIcons.mapPin(),
                                    size: 14,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    experience.location!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                else
                  // Desktop: Keep horizontal layout
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: experience.isCurrentJob
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.calendar(),
                              size: 14,
                              color: experience.isCurrentJob ? Theme.of(context).primaryColor : AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateRange(experience.startDate, experience.endDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: experience.isCurrentJob ? Theme.of(context).primaryColor : AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          duration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),

                      if (experience.location != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.mapPin(),
                                size: 14,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                experience.location!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                if (experience.description != null && experience.description!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  Text(experience.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                ],

                // Responsibilities
                if (experience.responsibilities.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Responsibilities:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      ...experience.responsibilities.map(
                        (responsibility) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  responsibility,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime startDate, DateTime? endDate) {
    final startMonth = _getMonthName(startDate.month);
    final startYear = startDate.year;

    if (endDate == null) {
      return '$startMonth $startYear - Present';
    }

    final endMonth = _getMonthName(endDate.month);
    final endYear = endDate.year;

    if (startYear == endYear && startDate.month == endDate.month) {
      return '$startMonth $startYear';
    } else if (startYear == endYear) {
      return '$startMonth - $endMonth $startYear';
    } else {
      return '$startMonth $startYear - $endMonth $endYear';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _calculateDuration(DateTime startDate, DateTime? endDate) {
    final end = endDate ?? DateTime.now();
    final difference = end.difference(startDate);
    final months = (difference.inDays / 30.44).round();

    if (months < 1) {
      return '1 month';
    } else if (months < 12) {
      return '$months months';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;

      if (remainingMonths == 0) {
        return years == 1 ? '1 year' : '$years years';
      } else {
        return years == 1 ? '1 year $remainingMonths months' : '$years years $remainingMonths months';
      }
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
              const Text('Clear All Experiences'),
            ],
          ),
          content: const Text('Are you sure you want to clear all work experiences? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearWorkExperiences();
                Navigator.of(context).pop();
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All work experiences cleared successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
