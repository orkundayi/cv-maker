import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/feature_gate_helper.dart';
import '../../../../core/utils/subscription_helper.dart';
import '../../../../core/widgets/ui_components.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cv_builder/data/services/firestore_cv_service.dart';
import '../../../cv_builder/presentation/pages/cv_builder_page.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/domain/feature_gate.dart';
import '../../../subscription/domain/subscription.dart';
import '../../../subscription/presentation/pages/pricing_page.dart';
import '../widgets/cv_list_item.dart';
import 'account_page.dart';

/// Modern dashboard page with ChatGPT-style sidebar
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  final FirestoreCVService _cvService = FirestoreCVService();
  List<CVMetadata> _cvList = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedCVId;
  bool _isProfileMenuExpanded = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadCVs();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCVs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );

      if (userId != null) {
        final cvs = await _cvService.getAllCVMetadata(userId);
        setState(() {
          _cvList = cvs;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewCV() async {
    final currentPlan = ref.read(currentPlanProvider);
    final canCreate = FeatureGate.canCreateNewCV(currentPlan, _cvList.length);

    if (!canCreate) {
      _showUpgradeDialog();
      return;
    }

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );

      if (userId != null) {
        final cvId = await _cvService.createNewCV(userId);
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CVBuilderPage(cvId: cvId)),
          );
          await _loadCVs();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar('${l10n.cvCreationFailed}: $e', isError: true);
      }
    }
  }

  void _showUpgradeDialog() {
    final theme = Theme.of(context);

    showDialog(
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
            PhosphorIconsFill.crown,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(AppLocalizations.of(context)!.cvLimit),
        content: Text(AppLocalizations.of(context)!.cvLimitReached),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
            icon: const Icon(PhosphorIconsRegular.crown, size: 18),
            label: Text(AppLocalizations.of(context)!.viewPlans),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCV(String cvId) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCV),
        content: Text(l10n.deleteCVConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authStateProvider);
        final userId = authState.maybeWhen(
          data: (user) => user?.uid,
          orElse: () => null,
        );

        if (userId != null) {
          await _cvService.deleteCVData(userId, cvId);
          _showSnackBar(l10n.cvDeleted);
          await _loadCVs();
        }
      } catch (e) {
        _showSnackBar('${l10n.cvDeleteFailed}: $e', isError: true);
      }
    }
  }

  Future<void> _duplicateCV(String cvId) async {
    final l10n = AppLocalizations.of(context)!;
    final currentPlan = ref.read(currentPlanProvider);
    final canCreate = FeatureGate.canCreateNewCV(currentPlan, _cvList.length);

    if (!canCreate) {
      _showUpgradeDialog();
      return;
    }

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );

      if (userId != null) {
        await _cvService.duplicateCV(cvId, userId);
        _showSnackBar(l10n.cvDuplicated);
        await _loadCVs();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('${l10n.cvDuplicateFailed}: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? PhosphorIconsRegular.warning
                  : PhosphorIconsRegular.check,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout(theme) : _buildMobileLayout(theme),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Sidebar with CV list
        _buildSidebar(theme),
        // Main content
        Expanded(
          child: Container(
            color: theme.colorScheme.surfaceContainerLowest,
            child: _buildMainContent(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    final currentUser = ref.watch(currentUserProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'CV Maker',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // New CV Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewCV,
                icon: const Icon(PhosphorIconsRegular.plus, size: 20),
                label: Text(l10n.newCV),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // CV List
          Expanded(child: _buildCVListInSidebar(theme)),

          // User profile with popup menu
          _buildUserProfileWithMenu(theme, currentUser, currentPlan),
        ],
      ),
    );
  }

  Widget _buildCVListInSidebar(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.errorOccurred,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    if (_cvList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.fileText,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                AppLocalizations.of(context)!.noCVsYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS),
      itemCount: _cvList.length,
      itemBuilder: (context, index) {
        final cv = _cvList[index];
        final isSelected = _selectedCVId == cv.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              onTap: () => _openCV(cv.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.fileText,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cv.title.isNotEmpty
                            ? cv.title
                            : AppLocalizations.of(context)!.newCV,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Actions popup
                    PopupMenuButton<String>(
                      icon: Icon(
                        PhosphorIconsRegular.dotsThree,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              const Icon(PhosphorIconsRegular.copy, size: 18),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.duplicate),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsRegular.trash,
                                size: 18,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.delete,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'duplicate') {
                          _duplicateCV(cv.id);
                        } else if (value == 'delete') {
                          _deleteCV(cv.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfileWithMenu(
    ThemeData theme,
    AsyncValue<AppUser?> currentUser,
    SubscriptionPlan currentPlan,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Menu items (shown when expanded)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 8),
                _buildProfileMenuItem(
                  theme: theme,
                  icon: PhosphorIconsRegular.user,
                  label: l10n.myAccount,
                  iconColor: theme.colorScheme.primary,
                  iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _isProfileMenuExpanded = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    ).then((_) => _loadCVs());
                  },
                ),
                _buildProfileMenuItem(
                  theme: theme,
                  icon: PhosphorIconsRegular.crown,
                  label: l10n.subscription,
                  iconColor: Colors.white,
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade400],
                  ),
                  onTap: () {
                    setState(() => _isProfileMenuExpanded = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PricingPage(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    height: 1,
                  ),
                ),
                _buildProfileMenuItem(
                  theme: theme,
                  icon: PhosphorIconsRegular.signOut,
                  label: l10n.signOut,
                  iconColor: theme.colorScheme.error,
                  iconBgColor: theme.colorScheme.error.withValues(alpha: 0.1),
                  textColor: theme.colorScheme.error,
                  onTap: () {
                    setState(() => _isProfileMenuExpanded = false);
                    _showSignOutDialog();
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
            crossFadeState: _isProfileMenuExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // Profile card (always visible, acts as toggle)
          InkWell(
            onTap: () => setState(
              () => _isProfileMenuExpanded = !_isProfileMenuExpanded,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: currentUser.when(
                data: (user) => Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        (user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0]
                                : user?.email.isNotEmpty == true
                                ? user!.email[0]
                                : 'U')
                            .toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? l10n.user,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            SubscriptionHelper.getDisplayName(
                              context,
                              currentPlan,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getPlanColor(currentPlan),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isProfileMenuExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        PhosphorIconsRegular.caretUp,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 40),
                error: (_, _) => const SizedBox(height: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBgColor,
    Color? textColor,
    Gradient? gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient == null ? iconBgColor : null,
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    final currentPlan = ref.watch(currentPlanProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.myCVs,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FeatureGateHelper.getRemainingCVMessage(
                        context,
                        currentPlan,
                        _cvList.length,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(child: _buildContent(theme)),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          _buildMobileHeader(theme),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(ThemeData theme) {
    final currentUser = ref.watch(currentUserProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_rounded,
                color: theme.colorScheme.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'CV Maker',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // User profile popup
            PopupMenuButton<String>(
              color: theme.colorScheme.surface,
              elevation: 8,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'account',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.user,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.myAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'subscription',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade600,
                              Colors.orange.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.crown,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.subscription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 16),
                PopupMenuItem(
                  value: 'signout',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.signOut,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.signOut,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'account') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountPage(),
                    ),
                  ).then((_) => _loadCVs());
                } else if (value == 'subscription') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PricingPage(),
                    ),
                  );
                } else if (value == 'signout') {
                  _showSignOutDialog();
                }
              },
              child: currentUser.when(
                data: (user) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          (user?.displayName?.isNotEmpty == true
                                  ? user!.displayName![0]
                                  : user?.email.isNotEmpty == true
                                  ? user!.email[0]
                                  : 'U')
                              .toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPlanColor(
                            currentPlan,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          SubscriptionHelper.getDisplayName(
                            context,
                            currentPlan,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getPlanColor(currentPlan),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(width: 40),
                error: (_, _) => const SizedBox(width: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(
        icon: PhosphorIconsRegular.warning,
        title: AppLocalizations.of(context)!.errorOccurred,
        subtitle: _error,
        buttonText: AppLocalizations.of(context)!.tryAgain,
        onButtonPressed: _loadCVs,
      );
    }

    if (_cvList.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsRegular.fileText,
        title: AppLocalizations.of(context)!.noCVsYet,
        subtitle: AppLocalizations.of(context)!.startCreatingCV,
        buttonText: AppLocalizations.of(context)!.createCV,
        onButtonPressed: _createNewCV,
      );
    }

    return _buildCVGrid(theme);
  }

  Widget _buildCVGrid(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isDesktop ? 320 : 400,
        childAspectRatio: isDesktop ? 1.2 : 1.4,
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
      ),
      itemCount: _cvList.length,
      itemBuilder: (context, index) {
        final cv = _cvList[index];
        return CVListItem(
          metadata: cv,
          onTap: () => _openCV(cv.id),
          onDelete: () => _deleteCV(cv.id),
          onDuplicate: () => _duplicateCV(cv.id),
        );
      },
    );
  }

  void _openCV(String cvId) {
    setState(() => _selectedCVId = cvId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CVBuilderPage(cvId: cvId)),
    ).then((_) {
      setState(() => _selectedCVId = null);
      _loadCVs();
    });
  }

  Color _getPlanColor(SubscriptionPlan plan) {
    final planStr = plan.toString().toLowerCase();
    if (planStr.contains('free')) return Colors.grey;
    if (planStr.contains('pro')) return Colors.amber.shade700;
    return Colors.purple;
  }
}
