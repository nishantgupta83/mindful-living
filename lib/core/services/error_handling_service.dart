import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Centralized Error Handling Service
///
/// Features:
/// - Firebase Crashlytics integration for production error tracking
/// - User-friendly error messages with SnackBar notifications
/// - Specific exception type handling (Firebase, Network, Platform)
/// - Development vs Production logging
/// - Error categorization and severity levels
///
/// Usage:
/// ```dart
/// try {
///   // Your code
/// } catch (e, stackTrace) {
///   ErrorHandlingService.instance.logError(
///     error: e,
///     stackTrace: stackTrace,
///     context: context,
///     userMessage: 'Failed to load data',
///   );
/// }
/// ```
class ErrorHandlingService {
  // Singleton pattern
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  static ErrorHandlingService get instance => _instance;
  ErrorHandlingService._internal();

  /// Initialize error handling service
  /// Call this once during app initialization
  Future<void> initialize() async {
    // Configure Crashlytics
    if (kReleaseMode) {
      // Enable Crashlytics collection in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Disable in debug mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('✅ ErrorHandlingService initialized');
  }

  /// Log error with optional user notification
  ///
  /// Parameters:
  /// - error: The error object
  /// - stackTrace: Optional stack trace
  /// - context: Optional BuildContext for showing SnackBar
  /// - userMessage: Optional user-friendly message (if null, no SnackBar shown)
  /// - severity: Error severity level (info, warning, error, critical)
  /// - showSnackBar: Whether to show SnackBar (default: true if context provided)
  void logError({
    required dynamic error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? userMessage,
    ErrorSeverity severity = ErrorSeverity.error,
    bool showSnackBar = true,
  }) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚨 ERROR [${severity.name.toUpperCase()}]: ${error.toString()}');
      if (stackTrace != null) {
        debugPrint('📍 Stack Trace:');
        debugPrint(stackTrace.toString());
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // Log to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: userMessage,
        fatal: severity == ErrorSeverity.critical,
      );
    }

    // Show user-facing error message
    if (context != null && showSnackBar && userMessage != null) {
      _showErrorSnackBar(context, userMessage, severity);
    }
  }

  /// Handle Firebase-specific errors with appropriate user messages
  void handleFirebaseError({
    required FirebaseException error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    final userMessage = customMessage ?? _getFirebaseErrorMessage(error);

    logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      severity: _getFirebaseErrorSeverity(error),
    );
  }

  /// Handle Firebase Auth errors specifically
  void handleAuthError({
    required FirebaseAuthException error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    final userMessage = customMessage ?? _getAuthErrorMessage(error);

    logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      severity: ErrorSeverity.warning,
    );
  }

  /// Handle Firestore errors specifically
  void handleFirestoreError({
    required FirebaseException error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    final userMessage = customMessage ?? _getFirestoreErrorMessage(error);

    logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      severity: ErrorSeverity.error,
    );
  }

  /// Handle network errors
  void handleNetworkError({
    required dynamic error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    final userMessage = customMessage ?? 'Network error. Please check your connection and try again.';

    logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      severity: ErrorSeverity.warning,
    );
  }

  /// Handle platform-specific errors
  void handlePlatformError({
    required PlatformException error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    final userMessage = customMessage ?? _getPlatformErrorMessage(error);

    logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      severity: ErrorSeverity.error,
    );
  }

  /// Show error SnackBar
  void _showErrorSnackBar(
    BuildContext context,
    String message,
    ErrorSeverity severity,
  ) {
    if (!context.mounted) return;

    final color = _getSeverityColor(severity);
    final icon = _getSeverityIcon(severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: severity == ErrorSeverity.critical ? 5 : 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Get user-friendly message for Firebase errors
  String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'cancelled':
        return 'Request was cancelled.';
      case 'data-loss':
        return 'Data corruption detected. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get user-friendly message for Firebase Auth errors
  String _getAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  /// Get user-friendly message for Firestore errors
  String _getFirestoreErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Access denied. Please sign in to continue.';
      case 'unavailable':
        return 'Database temporarily unavailable. Please try again.';
      case 'not-found':
        return 'Data not found.';
      case 'already-exists':
        return 'This item already exists.';
      default:
        return 'Database error. Please try again.';
    }
  }

  /// Get user-friendly message for Platform errors
  String _getPlatformErrorMessage(PlatformException error) {
    switch (error.code) {
      case 'sign_in_failed':
        return 'Sign-in failed. Please try again.';
      case 'sign_in_canceled':
        return 'Sign-in was cancelled.';
      case 'network_error':
        return 'Network error. Please check your connection.';
      default:
        return error.message ?? 'Platform error occurred.';
    }
  }

  /// Get severity level for Firebase errors
  ErrorSeverity _getFirebaseErrorSeverity(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return ErrorSeverity.warning;
      case 'data-loss':
      case 'internal':
        return ErrorSeverity.critical;
      default:
        return ErrorSeverity.error;
    }
  }

  /// Get color for severity level
  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return const Color(0xFF2196F3); // Blue
      case ErrorSeverity.warning:
        return const Color(0xFFF5A623); // Orange
      case ErrorSeverity.error:
        return const Color(0xFFE74C3C); // Red
      case ErrorSeverity.critical:
        return const Color(0xFF8B0000); // Dark Red
    }
  }

  /// Get icon for severity level
  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }

  /// Log user action for debugging
  void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint('👤 User Action: $action ${parameters != null ? '- $parameters' : ''}');
    }

    if (kReleaseMode) {
      FirebaseCrashlytics.instance.log('User Action: $action ${parameters != null ? '- $parameters' : ''}');
    }
  }

  /// Set user identifier for Crashlytics
  void setUserIdentifier(String userId) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
    debugPrint('👤 User identifier set: $userId');
  }

  /// Set custom key-value for error context
  void setCustomKey(String key, dynamic value) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  /// Clear user identifier (on sign out)
  void clearUserIdentifier() {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.setUserIdentifier('');
    }
    debugPrint('👤 User identifier cleared');
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}
