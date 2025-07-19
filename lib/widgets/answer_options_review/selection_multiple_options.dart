import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/dynamic_image.dart'; // ✅ Import Dynamic Image Widget
import '../common/convert_text.dart';

class SelectionMultipleOptionsReview extends StatefulWidget {
  final String questionText;
  final List<String> options; // ✅ Text or Image URLs
  final List<String> selectedAnswers; // Changed from List<int> to List<String>
  final Function(List<String>) onAnswerSelected; // Updated function signature
  final String? questionTextImage;
  final String questionContext;

  const SelectionMultipleOptionsReview({
    Key? key,
    required this.questionText,
    required this.options,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    required this.questionContext,
    this.questionTextImage,
  }) : super(key: key);

  @override
  _SelectionMultipleOptionsReviewState createState() =>
      _SelectionMultipleOptionsReviewState();
}

class _SelectionMultipleOptionsReviewState
    extends State<SelectionMultipleOptionsReview> {
  List<String> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.from(widget.selectedAnswers);
  }

  void _toggleSelection(int index) {
    final optionValue = widget.options[index];
    setState(() {
      if (selectedAnswers.contains(optionValue)) {
        selectedAnswers.remove(optionValue);
      } else {
        selectedAnswers.add(optionValue);
      }
    });
    widget.onAnswerSelected(selectedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Display Question Text and Image (if available)
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),

        // Display Question Context
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ConvertText(
            text: widget.questionContext,
            textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
        ),

        SizedBox(height: 10),

        // ✅ Display Options (Text or Image)
        Column(
          children: List.generate(widget.options.length, (index) {
            final optionValue = widget.options[index];
            bool isSelected = selectedAnswers.contains(optionValue);
            bool isImage = Uri.tryParse(optionValue)?.hasAbsolutePath ?? false;

            return GestureDetector(
              onTap: () => _toggleSelection(index),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: isSelected ? Colors.blue : Colors.grey),
                  color:
                      isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? checked) => _toggleSelection(index),
                      activeColor: Colors.blue,
                    ),
                    Expanded(
                      child: isImage
                          ? DynamicImage(
                              imageUrl: optionValue,
                              maxWidth: 100) // ✅ Show Image
                          : ConvertText(
                              text: optionValue, // ✅ Show Text
                              textStyle: TextStyle(fontSize: 20),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
