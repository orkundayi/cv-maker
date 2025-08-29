import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.colors;
    final hasSummary = _summaryController.text.trim().isNotEmpty;

    return ResponsiveCard(
      title: l10n.professionalSummary,
      subtitle: l10n.summaryDescription,
      actions: hasSummary
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), size: 18),
                tooltip: l10n.clearSummary,
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
                color: colors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: colors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: colors.info, size: 20),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        l10n.writingTips,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: colors.info, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.keepItConcise,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        l10n.highlightKeyStrengths,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        l10n.mentionCareerGoals,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        l10n.useActionWords,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        l10n.tailorToRole,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.info),
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
                label: l10n.professionalSummary,
                hint: l10n.summaryHint,
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
                  statusColor = colors.warning;
                  statusText = l10n.tooShort;
                  statusBgColor = colors.warning.withOpacity(0.1);
                } else if (charCount > 500) {
                  statusColor = colors.error;
                  statusText = l10n.tooLong;
                  statusBgColor = colors.error.withOpacity(0.1);
                } else {
                  statusColor = colors.success;
                  statusText = l10n.perfectLength;
                  statusBgColor = colors.success.withOpacity(0.1);
                }

                return Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(color: colors.border.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.characterCount}: $charCount/500',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
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
                        backgroundColor: colors.grey300,
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
                color: colors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: colors.success.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined, color: ref.colors.success, size: 20),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        l10n.proTips,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: colors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    l10n.summaryGrabAttention,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.success),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(PhosphorIcons.warning(), color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(l10n.clearSummary),
            ],
          ),
          content: Text(l10n.clearSummaryConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                ref.read(cvDataProvider.notifier).clearSummary();
                _summaryController.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.summaryCleared), backgroundColor: ref.colors.success));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );
  }
}
