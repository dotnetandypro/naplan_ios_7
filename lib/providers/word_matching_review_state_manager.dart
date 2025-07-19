import 'package:flutter/material.dart';

// Special state manager for review mode to avoid modifying existing state
class WordMatchingReviewState {
  Map<String, String> userMatches = {}; // Stores matched words
  bool isInitialized = false;
  List<String> selectedAnswers = []; // Formatted answers

  // Updates selectedAnswers based on userMatches
  void updateSelectedAnswers() {
    selectedAnswers = userMatches.entries
        .map((entry) => "${entry.value}:${entry.key}")
        .toList();
  }
}

class WordMatchingReviewStateManager extends ChangeNotifier {
  // Map to store state for each question by ID
  final Map<int, WordMatchingReviewState> _questionsState = {};
  final Map<int, bool> _initializedQuestions = {};

  // Get or create state for a specific question
  WordMatchingReviewState getQuestionState(int questionId) {
    if (!_questionsState.containsKey(questionId)) {
      _questionsState[questionId] = WordMatchingReviewState();
    }
    return _questionsState[questionId]!;
  }

  // Check if a question has been initialized
  bool isQuestionInitialized(int questionId) {
    return _initializedQuestions[questionId] ?? false;
  }

  // Mark a question as initialized
  void markQuestionInitialized(int questionId) {
    _initializedQuestions[questionId] = true;
  }

  // Add a match for a specific question
  void addMatch(int questionId, String option, String category) {
    final state = getQuestionState(questionId);
    state.userMatches.removeWhere((key, value) => value == category);
    state.userMatches[option] = category;
    state.updateSelectedAnswers();
    notifyListeners();
  }

  // Remove a match for a specific question
  void removeMatch(int questionId, String option) {
    final state = getQuestionState(questionId);
    state.userMatches.remove(option);
    state.updateSelectedAnswers();
    notifyListeners();
  }

  // Reset state for a specific question
  void resetQuestion(int questionId) {
    if (_questionsState.containsKey(questionId)) {
      _questionsState.remove(questionId);
      _initializedQuestions.remove(questionId);
      notifyListeners();
    }
  }

  // Reset all state
  void resetAll() {
    _questionsState.clear();
    _initializedQuestions.clear();
    notifyListeners();
  }
}
