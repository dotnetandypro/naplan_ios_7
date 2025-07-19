import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Helper class with methods to help debug the application
class DebugHelper {
  /// Tag for logging
  static const String TAG = "DebugHelper";

  /// Enable this demo to see messages in the console
  static void showDebugMessages() {
    // Using our custom Logger utility for consistent logging
    Logger.debug(TAG, "Starting debug message test");

    // Regular print statements (which may not show in web console)
    print("Regular print statement - may not show in web console");

    // Debug messages through our logger (should work in all environments)
    Logger.debug(
        TAG, "Debug message through Logger - should show in all environments");
    Logger.error(TAG, "Error message example", Exception("Test exception"));

    // Force log even in release mode
    Logger.forceLog(TAG, "This message would show even in release mode");

    if (kIsWeb) {
      Logger.debug(TAG, "Running in web environment");
    } else {
      Logger.debug(TAG, "Running in native environment");
    }

    // Testing structured data
    Map<String, dynamic> testData = {
      "key1": "value1",
      "key2": 123,
      "key3": {"nested": "value"}
    };

    Logger.debug(TAG, "Structured data test: $testData");

    Logger.debug(TAG, "Debug message test complete");
  }
}
