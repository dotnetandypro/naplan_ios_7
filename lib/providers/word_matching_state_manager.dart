import 'package:flutter/material.dart';

class WordMatchingQuestionState {
  Map<String, String> userMatches = {}; // Stores matched words
  Set<String> remainingOptions = {}; // Available options
  bool isInitialized = false;
  List<String> selectedAnswers = []; // Formatted answers

  // Updates selectedAnswers based on userMatches
  void updateSelectedAnswers() {
    selectedAnswers = userMatches.entries
        .map((entry) => "${entry.value}:${entry.key}")
        .toList();
  }
}

class WordMatchingStateManager extends ChangeNotifier {
  // Map to store state for each question by ID
  final Map<int, WordMatchingQuestionState> _questionsState = {};

  // Get or create state for a specific question
  WordMatchingQuestionState getQuestionState(int questionId) {
    if (!_questionsState.containsKey(questionId)) {
      _questionsState[questionId] = WordMatchingQuestionState();
    }
    return _questionsState[questionId]!;
  }

  // Initialize options for a specific question
  void initialize(int questionId, List<String> options) {
    final state = getQuestionState(questionId);
    if (!state.isInitialized) {
      state.remainingOptions = Set.from(options);
      state.isInitialized = true;
      notifyListeners();
    }
  }

  // Add a match for a specific question
  void addMatch(int questionId, String option, String category) {
    final state = getQuestionState(questionId);
    state.userMatches.removeWhere((key, value) => value == category);
    state.userMatches[option] = category;
    state.remainingOptions.remove(option);
    state.updateSelectedAnswers();
    notifyListeners();
  }

  // Remove a match for a specific question
  void removeMatch(int questionId, String option) {
    final state = getQuestionState(questionId);
    state.userMatches.remove(option);
    state.remainingOptions.add(option);
    state.updateSelectedAnswers();
    notifyListeners();
  }

  // Reset state for a specific question
  void resetQuestion(int questionId) {
    if (_questionsState.containsKey(questionId)) {
      _questionsState.remove(questionId);
      notifyListeners();
    }
  }

  // Reset all state
  void resetAll() {
    _questionsState.clear();
    notifyListeners();
  }
}
