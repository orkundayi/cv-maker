import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';

/// Certificates section widget
class CertificatesSection extends ConsumerStatefulWidget {
  const CertificatesSection({super.key});

  @override
  ConsumerState<CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends ConsumerState<CertificatesSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _credentialIdController = TextEditingController();
  final _urlController = TextEditingController();

  // Focus nodes for proper tab navigation
  final _nameFocusNode = FocusNode();
  final _issuerFocusNode = FocusNode();
  final _credentialIdFocusNode = FocusNode();
  final _urlFocusNode = FocusNode();
  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _hasExpiryDate = false;
  Certificate? _editingCertificate;

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialIdController.dispose();
    _urlController.dispose();

    // Dispose focus nodes
    _nameFocusNode.dispose();
    _issuerFocusNode.dispose();
    _credentialIdFocusNode.dispose();
    _urlFocusNode.dispose();

    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _issuerController.clear();
    _credentialIdController.clear();
    _urlController.clear();
    _issueDate = null;
    _expiryDate = null;
    _hasExpiryDate = false;
    _editingCertificate = null;

    // Clear focus
    _nameFocusNode.unfocus();
  }

  void _editCertificate(Certificate certificate) {
    setState(() {
      _editingCertificate = certificate;
      _nameController.text = certificate.name;
      _issuerController.text = certificate.issuer;
      _credentialIdController.text = certificate.credentialId ?? '';
      _urlController.text = certificate.url ?? '';
      _issueDate = certificate.issueDate;
      _expiryDate = certificate.expiryDate;
      _hasExpiryDate = certificate.expiryDate != null;
    });

    // Focus on the first field when editing
    _nameFocusNode.requestFocus();
  }

  void _deleteCertificate(String id) {
    ref.read(cvDataProvider.notifier).removeCertificate(id);
    if (_editingCertificate?.id == id) {
      _resetForm();
    }
  }

  void _selectIssueDate() {
    _showDateSelector(context, true);
  }

  void _selectExpiryDate() {
    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select issue date first'), backgroundColor: AppColors.warning),
      );
      return;
    }
    _showDateSelector(context, false);
  }

  void _showDateSelector(BuildContext context, bool isIssueDate) {
    // Generate years from 1950 to current year + 50 (reasonable range)
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1949 + 50, (index) => 1950 + index);
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

    int selectedYear = isIssueDate
        ? (_issueDate?.year ?? DateTime.now().year)
        : (_expiryDate?.year ?? DateTime.now().year);
    int selectedMonth = isIssueDate ? (_issueDate?.month ?? 1) : (_expiryDate?.month ?? 1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIssueDate ? 'Select Issue Date' : 'Select Expiry Date'),
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

              if (isIssueDate) {
                setState(() {
                  _issueDate = selectedDate;
                  // Only reset expiry date if it's before issue date (basic validation)
                  if (_expiryDate != null && _expiryDate!.isBefore(selectedDate)) {
                    _expiryDate = null;
                  }
                });
              } else {
                setState(() {
                  _expiryDate = selectedDate;
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

  void _saveCertificate() {
    if (!_formKey.currentState!.validate()) return;

    if (_issueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an issue date'), backgroundColor: AppColors.error));
      return;
    }

    if (_hasExpiryDate && _expiryDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an expiry date'), backgroundColor: AppColors.error));
      return;
    }

    // Only validate that expiry date is not before issue date
    // Allow old certificates and future expiry dates
    if (_expiryDate != null && _expiryDate!.isBefore(_issueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry date cannot be before issue date'), backgroundColor: AppColors.error),
      );
      return;
    }

    final certificate = Certificate(
      id: _editingCertificate?.id,
      name: _nameController.text.trim(),
      issuer: _issuerController.text.trim(),
      issueDate: _issueDate!,
      expiryDate: _hasExpiryDate ? _expiryDate : null,
      credentialId: _credentialIdController.text.trim().isEmpty ? null : _credentialIdController.text.trim(),
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
    );

    if (_editingCertificate != null) {
      ref.read(cvDataProvider.notifier).updateCertificate(certificate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate updated successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      ref.read(cvDataProvider.notifier).addCertificate(certificate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate added successfully!'), backgroundColor: AppColors.success),
      );
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final certificates = ref.watch(cvDataProvider).certificates;

    return ResponsiveCard(
      title: 'Certifications & Licenses',
      subtitle: 'Professional credentials and achievements',
      actions: certificates.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), color: Colors.red, size: 18),
                tooltip: 'Clear All Certificates',
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
          // Add/Edit Certificate Form
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: _editingCertificate != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: _editingCertificate != null ? AppColors.primary : AppColors.border,
                width: _editingCertificate != null ? 2 : 1,
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
                            if (_editingCertificate != null) ...[
                              Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary, size: 20),
                              const SizedBox(width: AppConstants.spacingS),
                            ],
                            Text(
                              _editingCertificate != null ? 'Edit Certificate' : 'Add New Certificate',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                        if (_editingCertificate != null)
                          TextButton.icon(
                            onPressed: _resetForm,
                            icon: Icon(PhosphorIcons.x()),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Certificate Name and Issuer
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Certificate Name',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            hint: 'e.g., AWS Solutions Architect, PMP',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Certificate name is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _issuerFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'Issuing Organization',
                          isRequired: true,
                          child: CustomTextFormField(
                            controller: _issuerController,
                            focusNode: _issuerFocusNode,
                            hint: 'e.g., Amazon Web Services, PMI',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Issuing organization is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _credentialIdFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Issue Date and Expiry Date
                    // Note: You can select any date - no restrictions!
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Issue Date',
                          isRequired: true,
                          child: InkWell(
                            onTap: _selectIssueDate,
                            child: CustomTextFormField(
                              controller: TextEditingController(
                                text: _issueDate != null
                                    ? '${_issueDate!.year.toString().padLeft(4, '0')}-${_issueDate!.month.toString().padLeft(2, '0')}'
                                    : '',
                              ),
                              hint: 'YYYY-MM',
                              enabled: false,
                            ),
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'Expiry Date',
                          child: _hasExpiryDate
                              ? InkWell(
                                  onTap: _selectExpiryDate,
                                  child: CustomTextFormField(
                                    controller: TextEditingController(
                                      text: _expiryDate != null
                                          ? '${_expiryDate!.year.toString().padLeft(4, '0')}-${_expiryDate!.month.toString().padLeft(2, '0')}'
                                          : '',
                                    ),
                                    hint: 'YYYY-MM',
                                    enabled: false,
                                  ),
                                )
                              : CustomTextFormField(
                                  controller: TextEditingController(text: 'No expiry'),
                                  enabled: false,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Has Expiry Date Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _hasExpiryDate,
                          onChanged: (value) {
                            setState(() {
                              _hasExpiryDate = value ?? false;
                              if (!_hasExpiryDate) {
                                _expiryDate = null;
                              }
                            });
                          },
                        ),
                        const Text('This certificate has an expiry date'),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Credential ID and URL
                    ResponsiveGrid(
                      children: [
                        ResponsiveFormField(
                          label: 'Credential ID (Optional)',
                          child: CustomTextFormField(
                            controller: _credentialIdController,
                            focusNode: _credentialIdFocusNode,
                            hint: 'e.g., AWS-12345, PMP-67890',
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _urlFocusNode.requestFocus();
                              });
                            },
                          ),
                        ),
                        ResponsiveFormField(
                          label: 'Verification URL (Optional)',
                          child: CustomTextFormField(
                            controller: _urlController,
                            focusNode: _urlFocusNode,
                            hint: 'https://verify.certificate.com',
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveCertificate,
                        icon: Icon(_editingCertificate != null ? PhosphorIcons.check() : PhosphorIcons.plus()),
                        label: Text(_editingCertificate != null ? 'Update Certificate' : 'Add Certificate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                          backgroundColor: _editingCertificate != null ? AppColors.success : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Certificates List
          if (certificates.isNotEmpty) ...[
            Text(
              'Your Certificates (${certificates.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...certificates.map(_buildCertificateCard),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(PhosphorIcons.certificate(), size: 64, color: AppColors.grey400),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No certificates added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Add your first certificate above',
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

  Widget _buildCertificateCard(Certificate certificate) {
    final isExpired = certificate.expiryDate != null && certificate.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        certificate.expiryDate != null &&
        certificate.expiryDate!.isAfter(DateTime.now()) &&
        certificate.expiryDate!.difference(DateTime.now()).inDays <= 30;

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
                        certificate.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        certificate.issuer,
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
                      onPressed: () => _editCertificate(certificate),
                      icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteCertificate(certificate.id),
                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Row(
              children: [
                Icon(PhosphorIcons.calendar(), size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Issued: ${certificate.issueDate.year}-${certificate.issueDate.month.toString().padLeft(2, '0')}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
                if (certificate.expiryDate != null) ...[
                  const SizedBox(width: AppConstants.spacingL),
                  Icon(
                    isExpired ? PhosphorIcons.warning() : PhosphorIcons.clock(),
                    size: 16,
                    color: isExpired ? AppColors.error : (isExpiringSoon ? AppColors.warning : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${certificate.expiryDate!.year}-${certificate.expiryDate!.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isExpired
                          ? AppColors.error
                          : (isExpiringSoon ? AppColors.warning : AppColors.textSecondary),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            if (certificate.credentialId != null) ...[
              const SizedBox(height: AppConstants.spacingS),
              Row(
                children: [
                  Icon(PhosphorIcons.identificationCard(), size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${certificate.credentialId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            if (certificate.url != null) ...[
              const SizedBox(height: AppConstants.spacingS),
              Row(
                children: [
                  Icon(PhosphorIcons.link(), size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      // Open URL in new tab
                      // html.window.open(certificate.url!, '_blank');
                    },
                    child: Text(
                      'Verify Certificate',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
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
              const Text('Clear All Certificates'),
            ],
          ),
          content: const Text('Are you sure you want to clear all certificates? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearCertificates();
                Navigator.of(context).pop();
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All certificates cleared successfully!'),
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
