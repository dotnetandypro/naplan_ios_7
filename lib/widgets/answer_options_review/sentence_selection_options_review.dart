import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class SentenceSelectionOptionsReview extends StatefulWidget {
  final String questionText;
  final String questionContext;
  final List<String> options;
  final List<String> selectedAnswers;
  final Function(List<String>) onAnswerSelected;
  final String? questionTextImage;

  const SentenceSelectionOptionsReview(
      {Key? key,
      required this.questionText,
      required this.questionContext,
      required this.options,
      required this.selectedAnswers,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  _SentenceSelectionOptionsReviewState createState() =>
      _SentenceSelectionOptionsReviewState();
}

class _SentenceSelectionOptionsReviewState
    extends State<SentenceSelectionOptionsReview> {
  late List<String> selectedWords;

  @override
  void initState() {
    super.initState();
    selectedWords = List<String>.from(widget.selectedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    List<String> words = widget.questionContext.split(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
            questionText: widget.questionText,
            questionTextImage: widget.questionTextImage),
        SizedBox(height: 10),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: words.map((word) {
            String cleanedWord = word.replaceAll(RegExp(r'[.,]'), '');
            bool isSelectable = widget.options.contains(cleanedWord);
            bool isSelected = selectedWords.contains(cleanedWord);

            return isSelectable
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedWords.remove(cleanedWord);
                        } else {
                          selectedWords.add(cleanedWord);
                        }
                      });
                      widget.onAnswerSelected(List<String>.from(selectedWords));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ConvertText(
                        text: word,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  )
                : ConvertText(
                    text: "$word ", textStyle: TextStyle(fontSize: 20));
          }).toList(),
        ),
      ],
    );
  }
}
