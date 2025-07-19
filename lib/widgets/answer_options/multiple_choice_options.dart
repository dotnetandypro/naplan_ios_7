import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class MultipleChoiceOptions extends StatelessWidget {
  final String questionText;
  final String questionContext;
  final List<String> options;
  final List<String> selectedAnswer;
  final Function(List<String>) onAnswerSelected;
  final String? questionTextImage;

  const MultipleChoiceOptions(
      {Key? key,
      required this.questionText,
      required this.questionContext,
      required this.options,
      required this.selectedAnswer,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (questionText.isNotEmpty) ...[
          QuestionTextWithImage(
              questionText: questionText, questionTextImage: questionTextImage),
          SizedBox(height: 8),
          if (questionContext.isNotEmpty)
            ConvertText(
              text: questionContext,
              textStyle: TextStyle(fontSize: 20),
            ),
          SizedBox(height: 14), // Increased spacing
        ],
        ...List.generate(
          options.length,
          (index) => RadioListTile<String>(
            title: ConvertText(
              text: options[index],
              textStyle: TextStyle(fontSize: 20), // Explicitly set font size
            ),
            value: options[index],
            groupValue: selectedAnswer.isNotEmpty ? selectedAnswer[0] : null,
            contentPadding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Added padding
            activeColor: Colors.blue,
            selected: selectedAnswer.isNotEmpty &&
                selectedAnswer[0] == options[index],
            onChanged: (String? value) {
              if (value != null) {
                onAnswerSelected([value]);
              }
            },
          ),
        ),
      ],
    );
  }
}
