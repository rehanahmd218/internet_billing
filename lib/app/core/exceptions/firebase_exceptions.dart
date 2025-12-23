import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Base class for readable exceptions
abstract class RException implements Exception {
  final String code;
  final String message;

  RException(this.code, this.message);

  @override
  String toString() => message;
}

/// -------------------- AUTH --------------------
class RFirebaseAuthException extends RException {
  RFirebaseAuthException(FirebaseAuthException e)
      : super(e.code, _mapAuthErrorCode(e.code));

  static String _mapAuthErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return "The email address is not valid.";
      case 'invalid-credential':
        return "User credentials are not correct.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password entered.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "The password is too weak.";
      case 'operation-not-allowed':
        return "This sign-in method is not enabled.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'requires-recent-login':
        return "Please log in again to perform this action.";
      default:
        return "An authentication error occurred. Please try again.";
    }
  }
}

/// -------------------- FIRESTORE & STORAGE --------------------
class RFirebaseException extends RException {
  RFirebaseException(FirebaseException e)
      : super(e.code, _mapFirebaseErrorCode(e.code));

  static String _mapFirebaseErrorCode(String code) {
    switch (code) {
      // Storage-specific errors
      case 'object-not-found':
        return "The requested file does not exist.";
      case 'unauthorized':
        return "You don't have permission to access this file.";
      case 'canceled':
        return "File upload was canceled.";
      case 'unknown':
        return "An unknown storage error occurred.";
      
      // Firestore-specific errors
      case 'not-found':
        return "The requested document does not exist.";
      case 'already-exists':
        return "This document already exists.";
      case 'resource-exhausted':
        return "Quota exceeded. Please try again later.";
      case 'failed-precondition':
        return "Operation failed. Please check your data and try again.";
      case 'aborted':
        return "Operation was aborted. Please try again.";
      case 'out-of-range':
        return "Invalid data range provided.";
      case 'unimplemented':
        return "This operation is not supported.";
      case 'internal':
        return "Internal server error. Please try again.";
      case 'data-loss':
        return "Data loss occurred. Please try again.";
      
      // General Firebase errors
      case 'network-request-failed':
        return "Network error. Please check your internet connection.";
      case 'permission-denied':
        return "You don't have permission to perform this action.";
      case 'unauthenticated':
        return "You must be signed in to perform this action.";
      case 'cancelled':
        return "The request was cancelled.";
      case 'unavailable':
        return "Service is currently unavailable. Try again later.";
      case 'deadline-exceeded':
        return "The request took too long. Please try again.";
      
      default:
        return "A Firebase error occurred. Please try again.";
    }
  }
}

/// -------------------- PLATFORM --------------------
class RPlatformChannelException extends RException {
  RPlatformChannelException(PlatformException e)
      : super(e.code, _mapPlatformErrorCode(e.code, e.message));

  static String _mapPlatformErrorCode(String code, String? message) {
    switch (code) {
      case 'NETWORK_ERROR':
        return "Network connection failed. Check your internet.";
      case 'PERMISSION_DENIED':
        return "Permission denied by platform.";
      case 'CANCELLED':
        return "The operation was cancelled.";
      case 'TIMEOUT':
        return "Operation timed out. Please try again.";
      case 'NOT_AVAILABLE':
        return "This feature is not available on your device.";
      default:
        return message ?? "A platform error occurred.";
    }
  }
}
