import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';
import '../../theme/app_theme.dart';

class WritingOptionsReview extends StatelessWidget {
  final String questionText;
  final String? questionTextImage;
  final String questionContext;
  final List<String> selectedAnswer;
  final Function(List<String>) onAnswerSelected;

  const WritingOptionsReview({
    Key? key,
    required this.questionText,
    required this.questionContext,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.questionTextImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse formatting from selectedAnswer in a simple implementation
    // A more advanced implementation would parse rich text
    bool isBold = false;
    bool isItalic = false;
    double fontSize = 28.0; // Set default font size to 28
    TextAlign textAlign = TextAlign.left;

    // Calculate available height for the text box
    final screenHeight = MediaQuery.of(context).size.height;
    // Reserve space for question text and other UI elements
    final reservedSpace = 180.0;
    // Use more vertical space - 70% of available height
    final textBoxHeight = math.max(400.0, screenHeight * 0.7 - reservedSpace);

    // Get the text from the list - use the first item if available
    String essayText = selectedAnswer.isNotEmpty ? selectedAnswer[0] : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text and image
        QuestionTextWithImage(
          questionText: questionText,
          questionTextImage: questionTextImage,
        ),

        // Question context
        if (questionContext.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ConvertText(
              text: questionContext,
              textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),

        SizedBox(height: 20),

        // Display writing response - with increased height
        Container(
          width: double.infinity,
          height: textBoxHeight,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(
              essayText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: textAlign,
            ),
          ),
        ),

        SizedBox(height: 10),

        // Word count display
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Word count: ${_getWordCount(essayText)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
