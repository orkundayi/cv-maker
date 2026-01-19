import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Helper function to translate auth error codes to localized messages
String getAuthErrorMessage(BuildContext context, String errorCode) {
  final l10n = AppLocalizations.of(context)!;

  switch (errorCode) {
    case 'account-creation-failed':
      return l10n.authErrorAccountCreationFailed;
    case 'login-failed':
      return l10n.authErrorLoginFailed;
    case 'email-already-in-use':
      return l10n.authErrorEmailInUse;
    case 'invalid-email':
      return l10n.authErrorInvalidEmail;
    case 'operation-not-allowed':
      return l10n.authErrorOperationNotAllowed;
    case 'weak-password':
      return l10n.authErrorWeakPassword;
    case 'user-disabled':
      return l10n.authErrorUserDisabled;
    case 'user-not-found':
      return l10n.authErrorUserNotFound;
    case 'wrong-password':
      return l10n.authErrorWrongPassword;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    case 'invalid-credential':
      return l10n.authErrorInvalidCredential;
    case 'generic':
    default:
      return l10n.authErrorGeneric;
  }
}
