import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';

/// Widget that wraps content and shows login page if user is not authenticated
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;

  const AuthWrapper({super.key, required this.child, this.requireAuth = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (requireAuth && user == null) {
          return const LoginPage();
        }
        return child;
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Bir hata oluştu: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(authStateProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that shows content only if user is logged in, otherwise shows nothing
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that shows content only if user is NOT logged in
class GuestGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const GuestGuard({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
