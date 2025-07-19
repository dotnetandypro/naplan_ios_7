import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';

class MultipleChoiceImageOptionsReview extends StatelessWidget {
  // Review: Class renamed to MultipleChoiceImageOptionsReview
  final String questionText;
  final List<String> options; // ✅ Image URLs
  final List<String> selectedAnswer; // Changed from int? to List<String>
  final Function(List<String>) onAnswerSelected; // Changed from Function(int)
  final String? questionTextImage;
  final double boxSize; // ✅ Customizable box size

  const MultipleChoiceImageOptionsReview({
    Key? key,
    required this.questionText,
    required this.options,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.questionTextImage,
    this.boxSize = 40, // ✅ Default size is 80px
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Display question text
        QuestionTextWithImage(
          questionText: questionText,
          questionTextImage: questionTextImage,
        ),
        SizedBox(height: 16),

        // ✅ Display images in a Grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent:
                boxSize * 1.5, // ✅ Ensure box scales with size input
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1, // ✅ Maintain square shape
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final String imageUrl = options[index];
            final bool isSelected = selectedAnswer.contains(imageUrl);

            return GestureDetector(
              onTap: () {
                // Create a new list with the selected image URL
                onAnswerSelected([imageUrl]);
              },
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color:
                        isSelected ? Colors.blueAccent : Colors.grey.shade400,
                    width: isSelected ? 4 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrl,
                    width: boxSize,
                    height: boxSize,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading image: $imageUrl");
                      return Icon(Icons.broken_image,
                          size: boxSize * 0.5, color: Colors.grey);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
