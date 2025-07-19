import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/question_type.dart';
import 'multiple_choice_options.dart';
import 'sentence_selection_options.dart';
import 'multiple_true_false_options.dart';
import 'drag_and_drop_image_question.dart';
import 'selection_multiple_options.dart';
import 'dropdown_selection_question.dart'; // ✅ Import new dropdown question
import 'multiple_choice_image_options.dart';
import 'drag_to_order_options.dart';
import 'drag_to_choice_options.dart'; // Import the new widget
import 'word_matching_options.dart';
import 'drag_to_group_options.dart';
import 'grid_to_choice_options.dart';
import 'fill_blank_options.dart';
import 'writing_options.dart'; // ✅ Import the writing options component

class AnswerOptions extends StatelessWidget {
  final Question question;
  final dynamic selectedAnswer;
  final Function(dynamic) onAnswerSelected;

  const AnswerOptions({
    Key? key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (question.type == QuestionType.multipleChoice) {
      return MultipleChoiceOptions(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswer: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.sentenceSelection) {
      return SentenceSelectionOptions(
          questionText: question.questionText,
          questionContext: question.questionContext!,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.multipleTrueFalse) {
      return MultipleTrueFalseOptions(
          questionText: question.questionText,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage,
          categories: question.categories);
    } else if (question.type == QuestionType.dragAndDropImages) {
      return DragAndDropImageQuestion(
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
      return SelectionMultipleOptions(
          questionText: question.questionText,
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ?? [],
          onAnswerSelected: onAnswerSelected,
          questionContext: question.questionContext ?? "",
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dropdownSelection) {
      // ✅ NEW: Dropdown Selection Support
      return DropdownSelectionQuestion(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>? ??
              [], // Changed from Map<String, String> to List<String>
          onSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.multipleChoiceImage) {
      return MultipleChoiceImageOptions(
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

      return DragToOrderOptions(
          questionText: question.questionText,
          options: question.options,
          selectedOrder: typedAnswer,
          onAnswerSelected: onAnswerSelected,
          categories: question.categories,
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dragToChoice) {
      return DragToChoiceOptions(
          questionText: question.questionText,
          questionContext: question.questionContext ?? "",
          options: question.options,
          selectedAnswers: selectedAnswer as List<String>,
          onAnswerSelected: onAnswerSelected,
          questionTextImage: question.questionTextImage,
          size: question.size ?? 1);
    } else if (question.type == QuestionType.wordMatching) {
      return WordMatchingOptions(
          questionId: question.id, // Pass the question ID
          questionText: question.questionText,
          options: question.options,
          categories: question.categories,
          onAnswerSelected: onAnswerSelected,
          questionContext: question.questionContext ?? "",
          questionTextImage: question.questionTextImage);
    } else if (question.type == QuestionType.dragToGroup) {
      return DragToGroupOptions(
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

      return SelectableGrid(
        questionText: question.questionText,
        questionTextImage: question.questionTextImage,
        gridSize: question.gridSize ?? 5,
        gridItems: question.gridItems!,
        onItemSelected: onAnswerSelected,
        selectedAnswer: typedAnswer,
      );
    } else if (question.type == QuestionType.fillTheBlank) {
      return FillBlankOptions(
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

      return WritingOptions(
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
