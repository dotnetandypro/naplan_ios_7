import 'package:flutter/material.dart';
import 'convert_text.dart';

class QuestionTextWithImage extends StatelessWidget {
  final String questionText;
  final String? questionTextImage;

  const QuestionTextWithImage({
    Key? key,
    required this.questionText,
    this.questionTextImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConvertText(
          text: questionText,
          textStyle: TextStyle(
            fontSize: 22, // Increased font size for question text
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (questionTextImage != null && questionTextImage!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.0), // Increased padding
            child: Center(
              child: SizedBox(
                height: 220, // Increased image height
                child: Image.network(
                  questionTextImage!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Text("Image not found", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
