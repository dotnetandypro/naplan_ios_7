import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/drag_and_drop_state_manager.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class DragAndDropImageQuestion extends StatelessWidget {
  final int questionId;
  final String questionText;
  final List<String> categories;
  final List<String> options;
  final Function(Map<String, String>, List<String>) onAnswerSelected;
  final String? questionTextImage;

  const DragAndDropImageQuestion(
      {Key? key,
      required this.questionId,
      required this.questionText,
      required this.categories,
      required this.options,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DragAndDropImageContent(
      questionId: questionId,
      questionText: questionText,
      categories: categories,
      options: options,
      onAnswerSelected: onAnswerSelected,
      questionTextImage: questionTextImage,
    );
  }
}

// Internal implementation that uses the global state manager
class _DragAndDropImageContent extends StatelessWidget {
  final int questionId;
  final String questionText;
  final List<String> categories;
  final List<String> options;
  final Function(Map<String, String>, List<String>) onAnswerSelected;
  final String? questionTextImage;

  const _DragAndDropImageContent(
      {Key? key,
      required this.questionId,
      required this.questionText,
      required this.categories,
      required this.options,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<DragAndDropStateManager>(context);
    stateManager.initialize(questionId, options);

    // Get the state for this specific question
    final questionState = stateManager.getQuestionState(questionId);

    return Column(
      children: [
        QuestionTextWithImage(
            questionText: questionText, questionTextImage: questionTextImage),
        SizedBox(height: 10),

        // ✅ Green Box: Original Positions (Draggable & Accepting Drops)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((imageUrl) {
            bool isPlaced = questionState.userMatches.containsKey(imageUrl);

            return DragTarget<String>(
              onWillAccept: (data) => true, // ✅ Allow dragging back to original
              onAccept: (imageUrl) {
                stateManager.removeMatch(
                    questionId, imageUrl); // ✅ Move back to original
                onAnswerSelected(
                    questionState.userMatches, questionState.selectedAnswers);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.green, width: 3), // ✅ Green Border
                    color: Colors.lightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: !isPlaced
                        ? Draggable<String>(
                            // ✅ Make Image Draggable
                            data: imageUrl,
                            feedback: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null, // ✅ Show empty green box if image is placed in drop zone
                  ),
                );
              },
            );
          }).toList(),
        ),

        SizedBox(height: 20),

        // ✅ Drop Zones (Categories)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: categories.map((category) {
            String? matchedImage = questionState.userMatches.entries
                .firstWhere((entry) => entry.value == category,
                    orElse: () => MapEntry("", ""))
                .key;

            return DragTarget<String>(
              onWillAccept: (data) => true,
              onAccept: (imageUrl) {
                stateManager.addMatch(questionId, imageUrl, category);
                onAnswerSelected(
                    questionState.userMatches, questionState.selectedAnswers);
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onDoubleTap: () {
                    if (matchedImage.isNotEmpty) {
                      stateManager.removeMatch(questionId, matchedImage);
                      onAnswerSelected(questionState.userMatches,
                          questionState.selectedAnswers);
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: matchedImage.isNotEmpty
                          ? Draggable<String>(
                              // ✅ Make Placed Image Draggable
                              data: matchedImage,
                              feedback: CachedNetworkImage(
                                imageUrl: matchedImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: CachedNetworkImage(
                                  imageUrl: matchedImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: matchedImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ConvertText(
                              text: category,
                              textStyle: TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
