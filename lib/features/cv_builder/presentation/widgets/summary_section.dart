import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';

/// Professional summary section widget
class SummarySection extends ConsumerStatefulWidget {
  const SummarySection({super.key});

  @override
  ConsumerState<SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends ConsumerState<SummarySection> {
  late final TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    final summary = ref.read(cvDataProvider).summary ?? '';
    _summaryController = TextEditingController(text: summary);
    _summaryController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    ref.read(cvDataProvider.notifier).updateSummary(_summaryController.text);
    setState(() {}); // Trigger rebuild to update character count
  }

  @override
  Widget build(BuildContext context) {
    final hasSummary = _summaryController.text.trim().isNotEmpty;

    return ResponsiveCard(
      title: 'Professional Summary',
      subtitle: 'Write a brief overview of your professional background and career goals',
      actions: hasSummary
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), color: Colors.red, size: 18),
                tooltip: 'Clear Summary',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]
          : null,
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tips section
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        'Writing Tips',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: AppColors.info, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Keep it concise (3-5 sentences, 100-500 characters)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        '• Highlight your key strengths and experience',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        '• Mention your career goals and what you bring',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        '• Use action words and quantifiable achievements',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        '• Tailor it to the specific role you\'re applying for',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Summary input field
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              child: CustomTextFormField(
                controller: _summaryController,
                label: 'Professional Summary',
                hint: 'Experienced software developer with 5+ years of expertise in full-stack development...',
                maxLines: 8,
                textInputAction: TextInputAction.newline,
              ),
            ),

            const SizedBox(height: AppConstants.spacingM),

            // Character count and progress
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _summaryController,
              builder: (context, value, child) {
                final charCount = value.text.length;
                final progress = (charCount / 500).clamp(0.0, 1.0);

                Color statusColor;
                String statusText;
                Color statusBgColor;

                if (charCount < 100) {
                  statusColor = AppColors.warning;
                  statusText = 'Too short';
                  statusBgColor = AppColors.warning.withOpacity(0.1);
                } else if (charCount > 500) {
                  statusColor = AppColors.error;
                  statusText = 'Too long';
                  statusBgColor = AppColors.error.withOpacity(0.1);
                } else {
                  statusColor = AppColors.success;
                  statusText = 'Perfect length';
                  statusBgColor = AppColors.success.withOpacity(0.1);
                }

                return Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Character count: $charCount/500',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: AppConstants.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              statusText,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.grey300,
                        valueColor: AlwaysStoppedAnimation(statusColor),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Additional tips
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, color: AppColors.success, size: 20),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        'Pro Tips',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Your summary should grab attention immediately. Start with your years of experience or key achievement, then mention 2-3 core skills, and end with what you\'re looking for or can contribute.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
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
              const Text('Clear Summary'),
            ],
          ),
          content: const Text(
            'Are you sure you want to clear your professional summary? This action cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearSummary();
                _summaryController.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Summary cleared successfully!'), backgroundColor: AppColors.success),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
