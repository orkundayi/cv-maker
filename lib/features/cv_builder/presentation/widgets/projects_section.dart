import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Projects section widget
class ProjectsSection extends ConsumerStatefulWidget {
  const ProjectsSection({super.key});

  @override
  ConsumerState<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends ConsumerState<ProjectsSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _urlController = TextEditingController();
  final _githubUrlController = TextEditingController();

  // Focus nodes for proper tab navigation
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _technologiesFocusNode = FocusNode();
  final _urlFocusNode = FocusNode();
  final _githubUrlFocusNode = FocusNode();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  Project? _editingProject;
  bool _isLaunchingUrl = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _urlController.dispose();
    _githubUrlController.dispose();

    // Dispose focus nodes
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _technologiesFocusNode.dispose();
    _urlFocusNode.dispose();
    _githubUrlFocusNode.dispose();

    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _technologiesController.clear();
    _urlController.clear();
    _githubUrlController.clear();
    _startDate = null;
    _endDate = null;
    _isOngoing = false;
    _editingProject = null;

    // Clear focus
    _nameFocusNode.unfocus();
  }

  void _editProject(Project project) {
    setState(() {
      _editingProject = project;
      _nameController.text = project.name;
      _descriptionController.text = project.description;
      _technologiesController.text = project.technologies.join(', ');
      _urlController.text = project.url ?? '';
      _githubUrlController.text = project.githubUrl ?? '';
      _startDate = project.startDate;
      _endDate = project.endDate;
      _isOngoing = project.isOngoing;
    });

    // Focus on the first field when editing
    _nameFocusNode.requestFocus();
  }

  void _deleteProject(String id) {
    ref.read(cvDataProvider.notifier).removeProject(id);
    if (_editingProject?.id == id) {
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
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartDate), backgroundColor: ref.colors.error));
      return;
    }
    _showDateSelector(context, false);
  }

  void _showDateSelector(BuildContext context, bool isStartDate) {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1949 + 50, (index) => 1950 + index);
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
                  // Reset end date if it's before start date
                  if (_endDate != null && _endDate!.isBefore(selectedDate)) {
                    _endDate = null;
                  }
                });
              } else {
                setState(() {
                  _endDate = selectedDate;
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

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartDate), backgroundColor: ref.colors.error));
      return;
    }

    if (!_isOngoing && _endDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectEndDateOrMarkCurrent), backgroundColor: ref.colors.error));
      return;
    }

    final project = Project(
      id: _editingProject?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      technologies: _technologiesController.text.trim().isEmpty
          ? []
          : _technologiesController.text.trim().split(',').map((e) => e.trim()).toList(),
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      githubUrl: _githubUrlController.text.trim().isEmpty ? null : _githubUrlController.text.trim(),
      startDate: _startDate!,
      endDate: _isOngoing ? null : _endDate,
      isOngoing: _isOngoing,
    );

    if (_editingProject != null) {
      final l10n = AppLocalizations.of(context)!;
      ref.read(cvDataProvider.notifier).updateProject(project);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.projects), backgroundColor: ref.colors.success));
    } else {
      ref.read(cvDataProvider.notifier).addProject(project);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.projects), backgroundColor: ref.colors.success),
      );
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(cvDataProvider).projects;

    return ResponsiveCard(
      title: l10n.portfolioProjects,
      subtitle: l10n.projectsDescription,
      actions: projects.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), size: 18),
                tooltip: l10n.clearAllProjects,
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
          // Add/Edit Project Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingProject != null
                  ? ref.colors.primary.withOpacity(0.05)
                  : ref.colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingProject != null ? ref.colors.primary : ref.colors.border,
                width: _editingProject != null ? 2 : 1,
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
                            if (_editingProject != null) ...[
                              Icon(PhosphorIcons.pencilSimple(), color: ref.colors.primary, size: 20),
                              const SizedBox(width: AppConstants.spacingS),
                            ],
                            Text(
                              _editingProject != null ? l10n.editProject : l10n.addProject,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: ref.colors.primary),
                            ),
                          ],
                        ),
                        if (_editingProject != null)
                          TextButton.icon(
                            onPressed: _resetForm,
                            icon: Icon(PhosphorIcons.x()),
                            label: Text(l10n.cancel),
                            style: TextButton.styleFrom(foregroundColor: ref.colors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Project Title
                    ResponsiveFormField(
                      label: l10n.projectName,
                      isRequired: true,
                      child: CustomTextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        hint: l10n.projectNameHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.firstNameRequired;
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _descriptionFocusNode.requestFocus();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Description
                    ResponsiveFormField(
                      label: l10n.description,
                      child: CustomTextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        hint: l10n.descriptionHint,
                        maxLines: 4,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _technologiesFocusNode.requestFocus();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Technologies and URLs
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: l10n.technologies,
                          child: CustomTextFormField(
                            controller: _technologiesController,
                            focusNode: _technologiesFocusNode,
                            hint: l10n.technologiesHint,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _urlFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: l10n.projectUrl,
                          child: CustomTextFormField(
                            controller: _urlController,
                            focusNode: _urlFocusNode,
                            hint: l10n.urlHint,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _githubUrlFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // GitHub URL
                    ResponsiveFormField(
                      label: l10n.githubUrl,
                      child: CustomTextFormField(
                        controller: _githubUrlController,
                        focusNode: _githubUrlFocusNode,
                        hint: l10n.githubUrlHint,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Start Date and End Date
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: l10n.startDate,
                          isRequired: true,
                          child: InkWell(
                            onTap: _selectStartDate,
                            child: CustomTextFormField(
                              controller: TextEditingController(
                                text: _startDate != null
                                    ? '${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}'
                                    : '',
                              ),
                              hint: 'YYYY-MM',
                              enabled: false,
                            ),
                          ),
                        ),
                        ResponsiveFormField(
                          label: l10n.endDate,
                          child: _isOngoing
                              ? CustomTextFormField(
                                  controller: TextEditingController(text: l10n.currentlyWorking),
                                  enabled: false,
                                )
                              : InkWell(
                                  onTap: _selectEndDate,
                                  child: CustomTextFormField(
                                    controller: TextEditingController(
                                      text: _endDate != null
                                          ? '${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}'
                                          : '',
                                    ),
                                    hint: 'YYYY-MM',
                                    enabled: false,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Ongoing Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isOngoing,
                          onChanged: (value) {
                            setState(() {
                              _isOngoing = value ?? false;
                              if (_isOngoing) {
                                _endDate = null;
                              }
                            });
                          },
                        ),
                        Text(l10n.currentlyWorking),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProject,
                        icon: Icon(_editingProject != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                        label: Text(_editingProject != null ? l10n.editProject : l10n.addProject),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                          backgroundColor: _editingProject != null ? ref.colors.success : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Projects List
          if (projects.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.folder(PhosphorIconsStyle.bold),
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.portfolioProjects,
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
                    '${projects.length}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),
            _buildProjectsGrid(projects),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.folder(), size: 64, color: ref.colors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    l10n.projectsDescription,
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

  Widget _buildProjectsGrid(List<Project> projects) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      // Mobile: Single column layout
      return Column(children: projects.map(_buildModernProjectCard).toList());
    } else {
      // Desktop: Grid layout
      return Wrap(
        spacing: AppConstants.spacingL,
        runSpacing: AppConstants.spacingL,
        children: projects
            .map(
              (project) => SizedBox(
                width: (MediaQuery.of(context).size.width - 120) / 2 - AppConstants.spacingL,
                child: _buildModernProjectCard(project),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildModernProjectCard(Project project) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final techList = project.technologies;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editProject(project),
                          icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: AppLocalizations.of(context)!.edit,
                        ),
                        IconButton(
                          onPressed: () => _deleteProject(project.id),
                          icon: Icon(PhosphorIcons.trash(), size: 20, color: ref.colors.error),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: AppLocalizations.of(context)!.delete,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingS),

                // Project status and duration
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: project.isOngoing
                            ? ref.colors.success.withOpacity(0.1)
                            : ref.colors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: project.isOngoing
                              ? ref.colors.success.withOpacity(0.3)
                              : ref.colors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: project.isOngoing ? ref.colors.success : ref.colors.info,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            project.isOngoing ? 'In Progress' : 'Completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: project.isOngoing ? ref.colors.success : ref.colors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.calendar(),
                              size: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatProjectDate(project.startDate, project.endDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (project.description.isNotEmpty) ...[
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                ],

                // Technologies
                if (techList.isNotEmpty) ...[
                  Text(
                    'Technologies:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: techList
                        .map(
                          (tech) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                            ),
                            child: Text(
                              tech,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                ],

                // Links
                if (project.url != null || project.githubUrl != null) ...[
                  Row(
                    children: [
                      if (project.url != null) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLaunchingUrl ? null : () => _launchUrl(project.url!),
                            icon: _isLaunchingUrl
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(PhosphorIcons.globe(), size: 16),
                            label: Text(
                              _isLaunchingUrl
                                  ? AppLocalizations.of(context)!.linkOpened
                                  : AppLocalizations.of(context)!.liveDemo,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12, horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],

                      if (project.url != null && project.githubUrl != null) const SizedBox(width: 8),

                      if (project.githubUrl != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLaunchingUrl ? null : () => _launchUrl(project.githubUrl!),
                            icon: _isLaunchingUrl
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    ),
                                  )
                                : Icon(PhosphorIcons.githubLogo(), size: 16),
                            label: Text(
                              _isLaunchingUrl
                                  ? AppLocalizations.of(context)!.linkOpened
                                  : AppLocalizations.of(context)!.github,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12, horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatProjectDate(DateTime startDate, DateTime? endDate) {
    final startMonth = _getMonthName(startDate.month);
    final startYear = startDate.year;

    if (endDate == null) {
      return '$startMonth $startYear - Present';
    }

    final endMonth = _getMonthName(endDate.month);
    final endYear = endDate.year;

    if (startYear == endYear) {
      return '$startMonth - $endMonth $startYear';
    } else {
      return '$startMonth $startYear - $endMonth $endYear';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _launchUrl(String url) async {
    if (_isLaunchingUrl) return; // Prevent multiple launches

    setState(() {
      _isLaunchingUrl = true;
    });

    try {
      // Add https:// if not present
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      // Try using url_launcher first
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('canLaunchUrl returned false');
        }
      } catch (pluginError) {
        // If url_launcher fails, provide helpful message
        throw Exception('Unable to open URL. Please copy and open manually: $formattedUrl');
      }

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(PhosphorIcons.checkCircle(), color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Opening in browser...'),
              ],
            ),
            backgroundColor: ref.colors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(PhosphorIcons.warning(), color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(AppLocalizations.of(context)!.linkOpenError)),
                ],
              ),
              backgroundColor: ref.colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(PhosphorIcons.warning(), color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(AppLocalizations.of(context)!.linkOpenError)),
              ],
            ),
            backgroundColor: ref.colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingUrl = false;
        });
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
              Text(AppLocalizations.of(context)!.clearAllProjects),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.clearProjectsConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearProjects();
                Navigator.of(context).pop();
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.projectsCleared),
                    backgroundColor: ref.colors.success,
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
