import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ExamHeaderReview extends StatefulWidget {
  final String submittedTime;
  final double score;
  final double timeToTake;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Function(int) onQuestionSelected;
  final String uid; // Add uid parameter

  const ExamHeaderReview({
    Key? key,
    required this.submittedTime,
    required this.score,
    required this.timeToTake,
    required this.questions,
    required this.currentQuestionIndex,
    required this.onQuestionSelected,
    required this.uid,
  }) : super(key: key);

  @override
  _ExamHeaderReviewState createState() => _ExamHeaderReviewState();
}

class _ExamHeaderReviewState extends State<ExamHeaderReview> {
  @override
  Widget build(BuildContext context) {
    // Format the submitted time
    DateTime parsedTime = DateTime.parse(widget.submittedTime);
    String formattedTime =
        DateFormat('MMM d, yyyy - h:mm a').format(parsedTime);

    // Format the timeToTake (minutes)
    int minutes = widget.timeToTake.floor();
    int seconds = ((widget.timeToTake - minutes) * 60).round();
    String formattedDuration = '${minutes}m ${seconds}s';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combined Score, Submission Time and Duration row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Submission info (removed ID to save space)
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.timer, color: Colors.white70, size: 18),
                    SizedBox(width: 4),
                    Text(
                      formattedDuration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Score
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Score: ${widget.score.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Question squares row with legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Questions:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),

              // Wrap for question squares
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  widget.questions.length,
                  (index) => _buildQuestionSquare(index),
                ),
              ),

              SizedBox(height: 12),

              // Legend with Report Button
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem(Colors.grey.shade400, "Not Answered"),
                  _buildLegendItem(Colors.orange, "Flagged"),
                  _buildLegendItem(Colors.green, "Correct"),
                  _buildLegendItem(Colors.red, "Incorrect"),
                  _buildReportButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionSquare(int index) {
    Question question = widget.questions[index];

    // Determine color based on question state
    Color squareColor = Colors.grey.shade400; // Default: Not answered

    if (question.userAnswer != null && question.userAnswer!.isNotEmpty) {
      if (question.isCorrect == true) {
        squareColor = Colors.green; // Correct
      } else {
        squareColor = Colors.red; // Incorrect
      }
    }

    if (question.isFlagged == true) {
      squareColor = Colors.orange; // Flagged takes precedence
    }

    // Highlight current question
    Border? border = (index == widget.currentQuestionIndex)
        ? Border.all(color: Colors.white, width: 2)
        : null;

    return GestureDetector(
      onTap: () => widget.onQuestionSelected(index),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: squareColor,
          border: border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "${index + 1}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReportButton() {
    return GestureDetector(
      onTap: () => _showReportDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.report_problem,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              "Report",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController _reportController = TextEditingController();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Report Question"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${widget.currentQuestionIndex + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please describe the issue with this question:",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _reportController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Describe the issue...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_reportController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter a message")),
                            );
                            return;
                          }

                          setState(() {
                            _isSubmitting = true;
                          });

                          await _submitReport(_reportController.text.trim());
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Submit Report"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String message) async {
    try {
      // Use the passed uid parameter instead of calling AuthService
      String uid = widget.uid;

      // Get current question ID
      int questionId = widget.questions[widget.currentQuestionIndex].id;

      // Prepare report data
      Map<String, dynamic> reportData = {
        "DateCreated": DateTime.now().toIso8601String(),
        "QuestionId": questionId,
        "Uid": uid,
        "message": message,
      };

      // Submit to API
      final response = await ApiService.post('reports', reportData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Report submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit report. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting report: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
