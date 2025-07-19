import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'start_screen.dart';
import 'attempt_list_screen.dart'; // Import the AttemptListScreen

class CategoryTestListScreen extends StatelessWidget {
  final Map<String, dynamic> categoryData;
  final String studentUid;

  const CategoryTestListScreen({
    Key? key,
    required this.categoryData,
    required this.studentUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String categoryName = categoryData['CategoryName'];
    final int yearLevel = categoryData['YearLevel'];
    final List<dynamic> listTests = categoryData['ListTests'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName.toLowerCase() == 'conventionsoflanguage'
            ? 'Conventions Of Language Tests - Year $yearLevel'
            : '$categoryName Tests - Year $yearLevel'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          image: DecorationImage(
            image: AssetImage('assets/images/nom_nom.jpg'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with category info
              _buildCategoryHeader(context),
              // List of tests
              Expanded(
                child: listTests.isEmpty
                    ? _buildEmptyState()
                    : _buildTestList(context, listTests),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context) {
    final Color cardColor = _getCategoryColor(categoryData['CategoryName']);
    final IconData categoryIcon =
        _getCategoryIcon(categoryData['CategoryName']);
    final int numberOfTests = categoryData['NumberOfTest'] ?? 0;
    final int completedTests = categoryData['NumberOfCompletedTest'] ?? 0;
    final double averageScore = (categoryData['AverageScore'] ?? 0).toDouble();

    return Container(
      padding: EdgeInsets.all(16),
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              SizedBox(width: 16),
              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Year ${categoryData['YearLevel']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCategoryNameForDisplay(
                          categoryData['CategoryName']),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedTests/$numberOfTests Tests Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Average: ${averageScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: numberOfTests > 0 ? completedTests / numberOfTests : 0,
              minHeight: 16,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList(BuildContext context, List<dynamic> tests) {
    // Debug: Print test info including IsAttemped status
    for (var test in tests) {
      print("Test: ${test['Title']} - IsAttemped: ${test['IsAttemped']}");
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: tests.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final test = tests[index];
        final bool isCompleted = _isTestCompleted(test);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                title: Text(
                  test['Title'] ?? 'Unnamed Test',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(test['Description'] ?? ''),
                    SizedBox(height: 4),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 400;
                        return Row(
                          children: [
                            Icon(Icons.timer,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text('${test['TimeInMinutes'] ?? 0} mins'),
                            SizedBox(width: 16),
                            Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text('${test['NumberOfQuestions'] ?? 0} questions'),
                            // Only show TestLevel on screens wider than 400px
                            if (!isSmallScreen) ...[
                              SizedBox(width: 16),
                              Icon(Icons.signal_cellular_alt,
                                  size: 16, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(_formatTestLevel(
                                  test['TestLevel'] ?? 'standard')),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Extract question list from the test
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StartScreen(
                        testId: test['Id'].toString(),
                        testDetails: test,
                        uid: studentUid,
                      ),
                    ),
                  );
                },
              ),
              // Add View Attempts button
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.history),
                      label: Text('View Attempts'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentColor,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // Navigate to AttemptListScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AttemptListScreen(
                              uid: studentUid,
                              testId: test['Id'].toString(),
                              testDetails: test,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No tests available for this category',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(String categoryName) {
    final Map<String, Color> categoryColors = {
      'conventionsoflanguage': Color(0xFF8E5DCF), // Purple
      'reading': Color(0xFF4285F4), // Blue
      'writing': Color(0xFF34A853), // Green
      'numeracy': Color(0xFFFBBC05), // Yellow/Orange
    };

    return categoryColors[categoryName.toLowerCase()] ?? Color(0xFF8E5DCF);
  }

  IconData _getCategoryIcon(String categoryName) {
    final Map<String, IconData> categoryIcons = {
      'conventionsoflanguage': Icons.spellcheck,
      'reading': Icons.menu_book,
      'writing': Icons.edit,
      'numeracy': Icons.calculate,
    };

    return categoryIcons[categoryName.toLowerCase()] ?? Icons.assessment;
  }

  String _formatCategoryNameForDisplay(String categoryName) {
    if (categoryName.toLowerCase() == 'conventionsoflanguage') {
      return 'CONVENTIONS OF LANGUAGE';
    }

    // Convert from camelCase
    return categoryName
        .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .toUpperCase();
  }

  String _formatTestLevel(String level) {
    switch (level.toLowerCase()) {
      case 'standard':
        return 'Standard';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return level;
    }
  }

  bool _isTestCompleted(Map<String, dynamic> test) {
    // Check if the test has been attempted, default to false if field doesn't exist
    return test['IsAttemped'] == true;
  }
}
