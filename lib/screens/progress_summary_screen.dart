import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';

class ProgressSummaryScreen extends StatefulWidget {
  final List<Question> questions;
  final List<dynamic> selectedAnswers;
  final List<bool> flaggedQuestions;
  final Function(int) onQuestionSelected;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isParent; // Added isParent parameter

  const ProgressSummaryScreen({
    Key? key,
    required this.questions,
    required this.selectedAnswers,
    required this.flaggedQuestions,
    required this.onQuestionSelected,
    required this.onSubmit,
    required this.onBack,
    this.isParent = false, // Default to false for backward compatibility
  }) : super(key: key);

  @override
  _ProgressSummaryScreenState createState() => _ProgressSummaryScreenState();
}

class _ProgressSummaryScreenState extends State<ProgressSummaryScreen> {
  String? _filterType;

  @override
  Widget build(BuildContext context) {
    int answeredCount =
        widget.selectedAnswers.where((answer) => _isAnswered(answer)).length;
    int notAnsweredCount = widget.questions.length - answeredCount;
    int flaggedCount = widget.flaggedQuestions.where((flag) => flag).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Summary"),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instruction Box with improved styling
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You have reached the end of the test",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "To check your answers, click a question number below.\nIf you are ready to finish the test, click Submit.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Filter Buttons with new styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton(
                  "Answered",
                  answeredCount,
                  AppTheme.primaryColor,
                  "answered",
                  Icons.check_circle_outline,
                ),
                _buildFilterButton(
                  "Not answered",
                  notAnsweredCount,
                  AppTheme.errorColor,
                  "not_answered",
                  Icons.help_outline,
                ),
                _buildFilterButton(
                  "Flagged",
                  flaggedCount,
                  AppTheme.warningColor,
                  "flagged",
                  Icons.flag_outlined,
                ),
              ],
            ),
            SizedBox(height: 24),

            // Question List Label
            Text(
              "Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Click a number to go to that question",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 16),

            // Question Grid with improved styling
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(widget.questions.length, (index) {
                      bool isAnswered =
                          _isAnswered(widget.selectedAnswers[index]);
                      bool isFlagged = widget.flaggedQuestions[index];

                      bool shouldShow = _filterType == null ||
                          (_filterType == "answered" && isAnswered) ||
                          (_filterType == "not_answered" && !isAnswered) ||
                          (_filterType == "flagged" && isFlagged);

                      Color itemColor = isAnswered
                          ? AppTheme.primaryColor
                          : isFlagged
                              ? AppTheme.warningColor
                              : Colors.grey.shade400;

                      return GestureDetector(
                        onTap: () => widget.onQuestionSelected(index),
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: shouldShow ? 1.0 : 0.3,
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: itemColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: itemColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (isFlagged)
                                  Positioned(
                                    right: 3,
                                    top: 3,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Back & Submit Buttons with improved styling
            Row(
              mainAxisAlignment: widget.isParent
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onBack,
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  label: Text("Back"),
                  style: AppTheme.outlineButtonStyle(),
                ),
                // Only show the Submit button if not in parent mode
                if (!widget.isParent)
                  ElevatedButton.icon(
                    onPressed: widget.onSubmit,
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text("Submit Test"),
                    style: AppTheme.successButtonStyle(),
                  ),
                // Show Exit to Test List button if in parent mode
                if (widget.isParent)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Pop back to the Package Test List Screen
                      // This will pop all screens back to the original Package Test List Screen
                      Navigator.of(context).popUntil((route) =>
                          route.isFirst ||
                          route.settings.name == '/packagetestlist');
                    },
                    icon: Icon(Icons.exit_to_app, color: Colors.white),
                    label: Text("Exit to Test List"),
                    style: AppTheme.primaryButtonStyle(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Create Clickable Filter Buttons with Icons
  Widget _buildFilterButton(
    String label,
    int count,
    Color color,
    String type,
    IconData icon,
  ) {
    bool isSelected = _filterType == type;

    return Material(
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _filterType = _filterType == type ? null : type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
              SizedBox(height: 4),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if a question is answered
  bool _isAnswered(dynamic answer) {
    if (answer is int) return answer != -1;
    if (answer is List<int>) return answer.any((item) => item != -1);
    if (answer is List<String>) return answer.any((item) => item.isNotEmpty);
    if (answer is List<String?>)
      return answer.any((item) => item != null && item.isNotEmpty);
    if (answer is Map<String, String>) return answer.isNotEmpty;
    if (answer is Map<String, List<String>>)
      return answer.values.any((list) => list.isNotEmpty);
    return false;
  }
}
