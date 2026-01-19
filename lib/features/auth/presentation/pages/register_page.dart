import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/auth_error_helper.dart';
import '../../../../core/widgets/ui_components.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Modern registration page with split layout for desktop
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref
        .read(authNotifierProvider.notifier)
        .signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.15;
    if (password.contains(RegExp('[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp('[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength.clamp(0, 1);
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getStrengthText(BuildContext context, double strength) {
    final l10n = AppLocalizations.of(context)!;
    if (strength < 0.3) return l10n.passwordStrengthWeak;
    if (strength < 0.6) return l10n.passwordStrengthMedium;
    if (strength < 0.8) return l10n.passwordStrengthGood;
    return l10n.passwordStrengthStrong;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    // Listen for auth state changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.errorCode != null && next.status == AuthStatus.error) {
        final errorMessage = getAuthErrorMessage(context, next.errorCode!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIconsRegular.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }

      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: isDesktop
              ? _buildDesktopLayout(theme)
              : _buildMobileLayout(theme),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Left side - Registration form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingXxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _buildRegisterForm(theme),
              ),
            ),
          ),
        ),
        // Right side - Branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_add_rounded,
                    size: 80,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    AppLocalizations.of(context)!.joinUs,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    AppLocalizations.of(context)!.joinUsDescription,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXxl),
                  _buildBenefitItem(
                    theme,
                    PhosphorIconsRegular.checkCircle,
                    AppLocalizations.of(context)!.benefit1,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildBenefitItem(
                    theme,
                    PhosphorIconsRegular.checkCircle,
                    AppLocalizations.of(context)!.benefit2,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildBenefitItem(
                    theme,
                    PhosphorIconsRegular.checkCircle,
                    AppLocalizations.of(context)!.benefit3,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildBenefitItem(
                    theme,
                    PhosphorIconsRegular.checkCircle,
                    AppLocalizations.of(context)!.benefit4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onPrimary, size: 24),
        const SizedBox(width: AppConstants.spacingM),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
            ),
          ),
        ),
        // Form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: _buildRegisterForm(theme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    final authState = ref.watch(authNotifierProvider);
    final passwordStrength = _getPasswordStrength(_passwordController.text);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassCard(
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Icon(
                  PhosphorIconsFill.userPlus,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppConstants.spacingM),
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  AppLocalizations.of(context)!.saveToCloud,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Name field
                CustomTextField(
                  controller: _nameController,
                  label: AppLocalizations.of(context)!.fullName,
                  prefixIcon: PhosphorIconsRegular.user,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.fullNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingM),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.email,
                  prefixIcon: PhosphorIconsRegular.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingM),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)!.password,
                  prefixIcon: PhosphorIconsRegular.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? PhosphorIconsRegular.eye
                          : PhosphorIconsRegular.eyeSlash,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShort;
                    }
                    return null;
                  },
                ),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingS),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: passwordStrength,
                            backgroundColor: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStrengthColor(passwordStrength),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        _getStrengthText(context, passwordStrength),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStrengthColor(passwordStrength),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppConstants.spacingM),

                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: AppLocalizations.of(context)!.confirmPassword,
                  prefixIcon: PhosphorIconsRegular.lockKey,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? PhosphorIconsRegular.eye
                          : PhosphorIconsRegular.eyeSlash,
                    ),
                    onPressed: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.confirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(context)!.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Register button
                AnimatedButton(
                  text: AppLocalizations.of(context)!.register,
                  isLoading:
                      _isLoading || authState.status == AuthStatus.loading,
                  onPressed: _signUp,
                  width: double.infinity,
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.alreadyHaveAccount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)!.loginAction,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
