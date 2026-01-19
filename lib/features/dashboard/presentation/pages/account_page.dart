import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/subscription_helper.dart';
import '../../../../core/utils/theme_helper.dart';
import '../../../../core/widgets/ui_components.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/theme_data.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/pages/pricing_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

/// Modern account page with professional design
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(PhosphorIconsRegular.arrowLeft),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    l10n.myAccount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                // Content
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? size.width * 0.15
                        : AppConstants.spacingM,
                    vertical: AppConstants.spacingM,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileCard(theme, l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildSubscriptionCard(theme, l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildThemeSection(theme, l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildLanguageSection(theme, l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildSupportCard(theme, l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildLogoutSection(theme, l10n),
                      const SizedBox(height: AppConstants.spacingXxl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, AppLocalizations l10n) {
    final currentUser = ref.watch(currentUserProvider);

    return GlassCard(
      child: currentUser.when(
        data: (user) => Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: user?.photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(user!.photoUrl!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        (user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0]
                                : user?.email[0] ?? 'U')
                            .toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: AppConstants.spacingL),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? l10n.user,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.activeMember,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacingL),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => Text(l10n.userLoadError),
      ),
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme, AppLocalizations l10n) {
    final subscription = ref.watch(subscriptionProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  PhosphorIconsFill.crown,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscription,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subscription.when(
                      data: (sub) => Text(
                        '${SubscriptionHelper.getDisplayName(context, sub.plan)} ${l10n.plan}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              AnimatedButton(
                text: l10n.upgrade,
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PricingPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Features
          subscription.when(
            data: (sub) => Column(
              children: [
                _buildFeatureRow(
                  theme,
                  PhosphorIconsRegular.fileText,
                  l10n.cvLimit,
                  sub.plan.maxCVs == -1
                      ? l10n.unlimited
                      : '${sub.plan.maxCVs} CV',
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  theme,
                  PhosphorIconsRegular.filePdf,
                  l10n.pdfExport,
                  sub.plan.canExportPDF ? l10n.active : l10n.inactive,
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection(ThemeData theme, AppLocalizations l10n) {
    final currentTheme = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.theme, subtitle: l10n.customizeAppearance),
        const SizedBox(height: AppConstants.spacingS),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: AppThemeType.values.map((themeType) {
              final isSelected = themeType == currentTheme;
              final colors = themeType.colorScheme;

              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingS),
                child: GestureDetector(
                  onTap: () {
                    ref.read(themeProvider.notifier).theme = themeType;
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.animationFast,
                    width: 70,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.primary, colors.primaryLight],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ThemeHelper.getThemeName(context, themeType),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colors.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(ThemeData theme, AppLocalizations l10n) {
    final currentLocale = ref.watch(languageProvider);
    final isTurkish = currentLocale.languageCode == 'tr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.language, subtitle: l10n.selectLanguage),
        const SizedBox(height: AppConstants.spacingS),
        Row(
          children: [
            // Turkish
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .changeLanguage(const Locale('tr'));
                },
                child: AnimatedContainer(
                  duration: AppConstants.animationFast,
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: isTurkish
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isTurkish ? 2 : 1,
                    ),
                    boxShadow: isTurkish
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🇹🇷', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Türkçe',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isTurkish
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isTurkish
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            // English
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .changeLanguage(const Locale('en'));
                },
                child: AnimatedContainer(
                  duration: AppConstants.animationFast,
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: !isTurkish
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: !isTurkish ? 2 : 1,
                    ),
                    boxShadow: !isTurkish
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'English',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: !isTurkish
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: !isTurkish
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.about),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIconsRegular.info,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(l10n.appName),
            subtitle: Text('${l10n.version} ${AppConstants.appVersion}'),
            onTap: _showAboutDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(ThemeData theme, AppLocalizations l10n) {
    return GlassCard(
      padding: EdgeInsets.zero,
      backgroundColor: theme.colorScheme.error.withValues(alpha: 0.02),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            PhosphorIconsRegular.signOut,
            size: 20,
            color: theme.colorScheme.error,
          ),
        ),
        title: Text(
          l10n.signOut,
          style: TextStyle(color: theme.colorScheme.error),
        ),
        onTap: _signOut,
      ),
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 64),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              '${l10n.version} ${AppConstants.appVersion}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              l10n.appDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIconsRegular.signOut,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        Navigator.of(context)
            .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            )
            .ignore();
      }
    }
  }
}
