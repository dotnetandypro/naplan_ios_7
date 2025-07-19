import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/drag_and_drop_state_manager.dart';
import 'providers/word_matching_state_manager.dart';
import 'screens/start_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/package_test_list_screen.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';
import 'utils/debug_helper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DragAndDropStateManager()),
        ChangeNotifierProvider(create: (context) => WordMatchingStateManager()),
      ],
      child: NaplanApp(),
    ),
  );
}

class NaplanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current URL
    final uri = Uri.base;
    final pathSegments = uri.pathSegments;

    // Use our custom logger for better visibility
    Logger.debug('Navigation', 'Current URL: ${uri.toString()}');
    Logger.debug('Navigation', 'Path segments: $pathSegments');

    // Show test debug messages
    if (kDebugMode) {
      DebugHelper.showDebugMessages();
    }

    // Determine the home widget based on URL
    Widget homeWidget;

    // Check if URL has specific path segments first
    if (pathSegments.isNotEmpty) {
      // Handle /studentdashboard/{uid} pattern
      if (pathSegments.length >= 2 && pathSegments[0] == 'studentdashboard') {
        final uid = pathSegments[1];
        print('Loading StudentDashboardScreen with uid: $uid');
        homeWidget = StudentDashboardScreen(uid: uid);
      }
      // Handle /reviewallquestions pattern
      else if (pathSegments.length == 1 &&
          pathSegments[0] == 'reviewallquestions') {
        print('Loading ExamScreen for reviewing all questions');
        homeWidget = ExamScreen();
      }
      // Handle /testpack/{testpackid}/{uid} pattern
      else if (pathSegments.length >= 3 && pathSegments[0] == 'testpack') {
        final testPackId = pathSegments[1];
        final uid = pathSegments[2];
        print(
            'Loading PackageTestListScreen with testPackId: $testPackId and uid: $uid');
        homeWidget = PackageTestListScreen(
          testPackId: testPackId,
          uid: uid,
        );
      } else {
        // Default case when path doesn't match any known pattern
        homeWidget = StudentDashboardScreen();
      }
    } else {
      // Default case - always show StudentDashboardScreen
      homeWidget = StudentDashboardScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NAPLAN 7 online test',
      theme: AppTheme.getTheme(),
      home: homeWidget,
      routes: {
        '/packagetestlist': (context) => PackageTestListScreen(
              testPackId:
                  uri.pathSegments.length >= 2 ? uri.pathSegments[1] : '',
              uid: uri.pathSegments.length >= 3 ? uri.pathSegments[2] : '',
            ),
      },
    );
  }
}

// This widget will extract URL parameters from the current window location
class ExamScreenWithParams extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current URL from window.location (for web)
    final uri = Uri.base;

    // Extract testId from query parameters
    final testId = uri.queryParameters['testId'];

    // Print for debugging
    print('Current URL: ${uri.toString()}');
    print('Extracted testId: $testId');

    // Pass the extracted testId to StartScreen instead of ExamScreen
    return StartScreen(testId: testId);
  }
}
