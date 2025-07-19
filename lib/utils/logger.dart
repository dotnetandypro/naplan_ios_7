import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logger utility class that provides consistent logging across platforms
class Logger {
  /// Log a debug message
  static void debug(String tag, dynamic message) {
    final logMessage = "[$tag] $message";

    if (kDebugMode) {
      // Using different logging implementations based on platform
      if (kIsWeb) {
        // For web, use console.log directly
        print(logMessage);
      } else {
        // For other platforms use dart:developer log
        developer.log(logMessage);
      }
    }
  }

  /// Log error message and exception
  static void error(String tag, dynamic message,
      [dynamic error, StackTrace? stackTrace]) {
    final logMessage = "[$tag] ERROR: $message";

    if (kDebugMode) {
      if (kIsWeb) {
        // For web, make sure errors are properly displayed
        print(logMessage);
        if (error != null) {
          print("Error details: $error");
        }
        if (stackTrace != null) {
          print("Stack trace: $stackTrace");
        }
      } else {
        developer.log(
          logMessage,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Force log to appear even in release mode (use sparingly)
  static void forceLog(String tag, dynamic message) {
    final logMessage = "[$tag] $message";

    // This will log in any mode (debug, profile, release)
    if (kIsWeb) {
      print(logMessage);
    } else {
      developer.log(logMessage);
    }
  }
}
