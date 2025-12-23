import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/exceptions/firebase_exceptions.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/core/utils/snackbar_utils.dart';

/// Safely executes a Firebase request with automatic exception handling and loader management
/// 
/// [request] - The Firebase operation to execute
/// [loader] - Optional RxBool to manage loading state (automatically set to true/false)
/// [showErrorSnackbar] - Whether to show error snackbar automatically (default: true)
/// 
/// Returns the result of the request or rethrows the exception after handling
Future<T> runFirebaseSafely<T>(
  Future<T> Function() request, {
  RxBool? loader,
  bool showErrorSnackbar = true,
}) async {
  try {
    // Start loader if provided
    if (loader != null) {
      loader.value = true;
    }

    // Execute the request
    return await request();
  } on FirebaseAuthException catch (e) {
    // Handle Firebase Auth exceptions
    final exception = RFirebaseAuthException(e);
    AppLogger.error('Firebase Auth Error: ${exception.code}', e);
    
    if (showErrorSnackbar) {
      SnackbarUtils.showError(exception.message);
    }
    
    throw exception;
  } on FirebaseException catch (e) {
    // Handle Firebase/Firestore exceptions
    final exception = RFirebaseException(e);
    AppLogger.error('Firebase Error: ${exception.code}', e);
    
    if (showErrorSnackbar) {
      SnackbarUtils.showError(exception.message);
    }
    
    throw exception;
  } on PlatformException catch (e) {
    // Handle Platform exceptions
    final exception = RPlatformChannelException(e);
    AppLogger.error('Platform Error: ${exception.code}', e);
    
    if (showErrorSnackbar) {
      SnackbarUtils.showError(exception.message);
    }
    
    throw exception;
  } catch (e, stackTrace) {
    // Handle unexpected exceptions
    AppLogger.error('Unexpected error in Firebase operation', e, stackTrace);
    
    if (showErrorSnackbar) {
      SnackbarUtils.showError('An unexpected error occurred. Please try again.');
    }
    
    rethrow;
  } finally {
    // Stop loader if provided
    if (loader != null) {
      loader.value = false;
    }
  }
}
