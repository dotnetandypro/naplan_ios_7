import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_model.dart';
import '../../models/question_type.dart';
import 'multiple_choice_options_review.dart';
import 'sentence_selection_options_review.dart';
import 'multiple_true_false_options_review.dart';
import 'drag_and_drop_image_question_review.dart';
import 'selection_multiple_options_review.dart';
import 'dropdown_selection_question_review.dart'; // ✅ Import new dropdown question
import 'multiple_choice_image_options_review.dart';
import 'drag_to_order_options_review.dart';
import 'drag_to_choice_options_review.dart'; // Import the new widget
import 'word_matching_options_review.dart';
import 'drag_to_group_options_review.dart';
import 'grid_to_choice_options_review.dart';
import 'fill_blank_options_review.dart';
import 'writing_options_review.dart'; // ✅ Import the writing options review component

class AnswerOptionsReview extends StatelessWidget {
  // Review: Class renamed to AnswerOptionsReview
  final Question question;
  final dynamic selectedAnswer;
  final Function(dynamic) onAnswerSelected;

  const AnswerOptionsReview({
    Key? key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (question.type == QuestionType.multipleChoice) {
      return MultipleChoiceOptionsReview(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswer: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.sentenceSelection) {
      return SentenceSelectionOptionsReview(
          questionText: question.questionText,
          questionContext: question.questionContext!,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.multipleTrueFalse) {
      return MultipleTrueFalseOptionsReview(
          questionText: question.questionText,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage,
          categories: question.categories);
    } else if (question.type == QuestionType.dragAndDropImages) {
      return DragAndDropImageQuestionReview(
          questionId: question.id, // Pass the question ID
          questionText: question.questionText,
          categories: question.categories,
          options: question.options,
          onAnswerSelected: (userMatches, selectedAnswersFormatted) {
            // Pass only the formatted list to the parent for storage
            onAnswerSelected(selectedAnswersFormatted);
          },
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.selectionMultiple) {
      return SelectionMultipleOptionsReview(
          questionText: question.questionText,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionContext: question.questionContext ?? "",
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dropdownSelection) {
      // ✅ NEW: Dropdown Selection Support
      return DropdownSelectionQuestionReview(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ??
              [], // Changed from Map<String, String> to List<String>
          onSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.multipleChoiceImage) {
      return MultipleChoiceImageOptionsReview(
          // ✅ Use image-based selection
          questionText: question.questionText,
          options: question.options, // ✅ Options are treated as image URLs
          selectedAnswer: selectedAnswer as List<String>? ??
              [], // Changed from int? to List<String>
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dragToOrder) {
      List<String?> typedAnswer;
      if (selectedAnswer is List<String?>) {
        typedAnswer = selectedAnswer;
      } else if (selectedAnswer is List<String>) {
        // Convert List<String> to List<String?>
        typedAnswer = selectedAnswer.map((s) => s as String?).toList();
      } else if (selectedAnswer is List) {
        // Handle generic list case
        typedAnswer = selectedAnswer.map((item) => item as String?).toList();
      } else {
        // Default to empty list if we can't properly convert
        typedAnswer = [];
      }

      return DragToOrderOptionsReview(
          questionText: question.questionText,
          options: question.options,
          selectedOrder: typedAnswer,
          onAnswerSelected: onAnswerSelected,
          categories: question.categories,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dragToChoice) {
      return DragToChoiceOptionsReview(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>,
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage,
          size: question.size ?? 1);
    } else if (question.type == QuestionType.wordMatching) {
      print("DEBUG - Word matching answers passing to review: $selectedAnswer");
      return Provider<List<String>>.value(
        value: selectedAnswer as List<String>? ?? [],
        child: WordMatchingOptionsReview(
          questionId: question.id,
          questionText: question.questionText,
          options: question.options,
          categories: question.categories,
          onAnswerSelected: onAnswerSelected,
          questionContext: question.questionContext ?? "",
          questionTextImage: question.questionTextImage,
        ),
      );
    } else if (question.type == QuestionType.dragToGroup) {
      return DragToGroupOptionsReview(
          questionText: question.questionText,
          questionContext: question.questionContext,
          options: question.options,
          categories: question.categories,
          selectedGroups: selectedAnswer as Map<String, List<String>>? ?? {},
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.gridToChoice) {
      // Convert to List<String> for the updated SelectableGrid interface
      List<String> typedAnswer;
      if (selectedAnswer is List<String>) {
        typedAnswer = selectedAnswer;
      } else if (selectedAnswer is int) {
        // Convert from old format (int) to new format (List<String>)
        typedAnswer = [selectedAnswer.toString()];
      } else {
        // Default to empty list if we can't properly convert
        typedAnswer = [];
      }

      return SelectableGridReview(
        questionText: question.questionText,
        questionTextImage: question.questionTextImage,
        gridSize: question.gridSize ?? 5,
        gridItems: question.gridItems!,
        onItemSelected: onAnswerSelected,
        selectedAnswer: typedAnswer,
      );
    } else if (question.type == QuestionType.fillTheBlank) {
      return FillBlankOptionsReview(
        questionText: question.questionText,
        questionTextImage: question.questionTextImage,
        size: question.size ?? 1,
        questionContext: question.questionContext!,
        onAnswerSelected: onAnswerSelected,
        selectedAnswers: selectedAnswer as List<String>,
      );
    } else if (question.type == QuestionType.narrativeWriting ||
        question.type == QuestionType.persuasiveWriting) {
      // Convert to List<String> for consistency with other question types
      List<String> typedAnswer;
      if (selectedAnswer is List<String>) {
        typedAnswer = selectedAnswer;
      } else if (selectedAnswer is String) {
        // Handle the case where it's passed as a single string
        typedAnswer = [selectedAnswer];
      } else {
        // Default to empty list if we can't properly convert
        typedAnswer = [];
      }

      return WritingOptionsReview(
        questionText: question.questionText,
        questionTextImage: question.questionTextImage,
        questionContext: question.questionContext ?? "",
        selectedAnswer: typedAnswer,
        onAnswerSelected: onAnswerSelected,
      );
    }

    return SizedBox.shrink();
  }
}
