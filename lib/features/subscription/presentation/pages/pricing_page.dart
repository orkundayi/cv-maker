import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/subscription_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/subscription.dart';
import '../providers/subscription_provider.dart';

/// Pricing page showing subscription plans with modern design
class PricingPage extends ConsumerWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final currentPlan = ref.watch(currentPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.plans),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : AppConstants.spacingL,
            vertical: AppConstants.spacingL,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.spacingL),

              // Header with gradient text effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.onSurface,
                    theme.colorScheme.primary,
                  ],
                ).createShader(bounds),
                child: Text(
                  AppLocalizations.of(context)!.professionalizeYourCVs,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                AppLocalizations.of(context)!.choosePlanForYou,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXxl),

              // Plans
              if (isDesktop)
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlanCard(
                        plan: SubscriptionPlan.free,
                        isCurrentPlan: currentPlan == SubscriptionPlan.free,
                      ),
                      const SizedBox(width: AppConstants.spacingL),
                      Transform.scale(
                        scale: 1.05,
                        child: _PlanCard(
                          plan: SubscriptionPlan.pro,
                          isCurrentPlan: currentPlan == SubscriptionPlan.pro,
                          isPopular: true,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingL),
                      _PlanCard(
                        plan: SubscriptionPlan.premium,
                        isCurrentPlan: currentPlan == SubscriptionPlan.premium,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    _PlanCard(
                      plan: SubscriptionPlan.free,
                      isCurrentPlan: currentPlan == SubscriptionPlan.free,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    _PlanCard(
                      plan: SubscriptionPlan.pro,
                      isCurrentPlan: currentPlan == SubscriptionPlan.pro,
                      isPopular: true,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    _PlanCard(
                      plan: SubscriptionPlan.premium,
                      isCurrentPlan: currentPlan == SubscriptionPlan.premium,
                    ),
                  ],
                ),

              const SizedBox(height: AppConstants.spacingXxl),

              // Feature comparison
              const _FeatureComparisonTable(),

              const SizedBox(height: AppConstants.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isPopular;

  const _PlanCard({
    required this.plan,
    this.isCurrentPlan = false,
    this.isPopular = false,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    final planColors = _getPlanColors(widget.plan, theme);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isDesktop ? 300 : double.infinity,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: widget.isPopular
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: widget.isPopular
                  ? theme.colorScheme.primary.withValues(
                      alpha: _isHovered ? 0.4 : 0.25,
                    )
                  : theme.colorScheme.shadow.withValues(
                      alpha: _isHovered ? 0.15 : 0.08,
                    ),
              blurRadius: _isHovered ? 30 : 20,
              offset: Offset(0, _isHovered ? 15 : 10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.isPopular ? null : theme.colorScheme.surface,
            border: widget.isPopular
                ? null
                : Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
          ),
          child: Column(
            children: [
              // Popular badge
              if (widget.isPopular)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIconsFill.sparkle,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.mostPopular,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              // Use Expanded only in desktop mode (inside IntrinsicHeight/Row)
              // Use flexible container in mobile mode (inside Column)
              _buildCardContent(context, theme, l10n, planColors, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    _PlanColors planColors,
    bool isDesktop,
  ) {
    final content = Container(
      padding: const EdgeInsets.all(28),
      decoration: widget.isPopular
          ? BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      margin: widget.isPopular ? const EdgeInsets.fromLTRB(4, 0, 4, 4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isDesktop ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Plan icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: planColors.gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: planColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(planColors.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SubscriptionHelper.getDisplayName(context, widget.plan),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    SubscriptionHelper.getDescription(context, widget.plan),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (widget.plan.monthlyPrice > 0)
                Text(
                  '₺',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: planColors.primary,
                  ),
                ),
              Text(
                widget.plan.monthlyPrice == 0
                    ? l10n.free
                    : '${widget.plan.monthlyPrice.toInt()}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.plan.monthlyPrice == 0
                      ? theme.colorScheme.onSurface
                      : planColors.primary,
                ),
              ),
              if (widget.plan.monthlyPrice > 0) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '/${l10n.perMonth.replaceAll('/', '')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  planColors.primary.withValues(alpha: 0.3),
                  planColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Features
          ...SubscriptionHelper.getFeatures(context, widget.plan).map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: planColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      PhosphorIconsBold.check,
                      color: planColors.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Spacer only for desktop mode
          if (isDesktop) const Spacer(),
          if (!isDesktop) const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: widget.isCurrentPlan
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      l10n.currentPlan,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _onSelectPlan(context, widget.plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isPopular
                          ? theme.colorScheme.primary
                          : planColors.primary.withValues(alpha: 0.1),
                      foregroundColor: widget.isPopular
                          ? Colors.white
                          : planColors.primary,
                      elevation: widget.isPopular ? 4 : 0,
                      shadowColor: widget.isPopular
                          ? planColors.primary.withValues(alpha: 0.4)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.plan == SubscriptionPlan.free
                          ? l10n.startFree
                          : l10n.selectPlan,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );

    // Return Expanded only in desktop mode
    if (isDesktop) {
      return Expanded(child: content);
    }
    return content;
  }

  _PlanColors _getPlanColors(SubscriptionPlan plan, ThemeData theme) {
    switch (plan) {
      case SubscriptionPlan.free:
        return _PlanColors(
          primary: theme.colorScheme.secondary,
          icon: PhosphorIconsFill.user,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary,
              theme.colorScheme.secondary.withValues(alpha: 0.7),
            ],
          ),
        );
      case SubscriptionPlan.pro:
        return _PlanColors(
          primary: theme.colorScheme.primary,
          icon: PhosphorIconsFill.star,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
        );
      case SubscriptionPlan.premium:
        return _PlanColors(
          primary: Colors.purple,
          icon: PhosphorIconsFill.crown,
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
          ),
        );
    }
  }

  void _onSelectPlan(BuildContext context, SubscriptionPlan plan) {
    if (plan == SubscriptionPlan.free) {
      Navigator.pop(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${SubscriptionHelper.getDisplayName(context, plan)} ${l10n.plan}',
        ),
        content: Text(l10n.paymentIntegrationSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _PlanColors {
  final Color primary;
  final IconData icon;
  final Gradient gradient;

  _PlanColors({
    required this.primary,
    required this.icon,
    required this.gradient,
  });
}

class _FeatureComparisonTable extends StatelessWidget {
  const _FeatureComparisonTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final features = [
      {
        'name': l10n.cvCount,
        'free': '1',
        'pro': '5',
        'premium': l10n.unlimited,
      },
      {'name': l10n.basicTemplates, 'free': true, 'pro': true, 'premium': true},
      {
        'name': l10n.premiumTemplates,
        'free': false,
        'pro': true,
        'premium': true,
      },
      {'name': l10n.pdfExport, 'free': false, 'pro': true, 'premium': true},
      {'name': l10n.htmlExport, 'free': false, 'pro': true, 'premium': true},
      {'name': l10n.jsonExport, 'free': false, 'pro': false, 'premium': true},
      {'name': l10n.cloudStorage, 'free': true, 'pro': true, 'premium': true},
      {
        'name': l10n.customTemplates,
        'free': false,
        'pro': false,
        'premium': true,
      },
      {
        'name': l10n.prioritySupport,
        'free': false,
        'pro': true,
        'premium': true,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsFill.listChecks,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  l10n.featureComparison,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.feature,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                  ...[l10n.free, 'Pro', 'Premium'].map(
                    (plan) => Expanded(
                      flex: 2,
                      child: Text(
                        plan,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Table rows
            ...features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              final isEven = index.isEven;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isEven
                      ? Colors.transparent
                      : theme.colorScheme.onSurface.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        feature['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _FeatureValue(value: feature['free']),
                    _FeatureValue(value: feature['pro']),
                    _FeatureValue(value: feature['premium']),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FeatureValue extends StatelessWidget {
  final dynamic value;

  const _FeatureValue({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      flex: 2,
      child: Center(
        child: value is bool
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: value == true
                      ? Colors.green.withValues(alpha: 0.15)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  value == true
                      ? PhosphorIconsBold.check
                      : PhosphorIconsRegular.x,
                  color: value == true
                      ? Colors.green
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 16,
                ),
              )
            : Text(
                value.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
