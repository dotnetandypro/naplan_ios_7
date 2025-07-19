import 'package:flutter/material.dart';

class DragAndDropQuestionState {
  Map<String, String> userMatches = {}; // Stores dropped images
  Set<String> remainingImages = {}; // Available options
  bool isInitialized = false;
  List<String> selectedAnswers = []; // Formatted answers

  // Updates selectedAnswers based on userMatches
  void updateSelectedAnswers() {
    selectedAnswers = userMatches.entries
        .map((entry) => "${entry.value}:${entry.key}")
        .toList();
  }
}

class DragAndDropStateManager extends ChangeNotifier {
  // Map to store state for each question by ID
  final Map<int, DragAndDropQuestionState> _questionsState = {};

  // Get or create state for a specific question
  DragAndDropQuestionState getQuestionState(int questionId) {
    if (!_questionsState.containsKey(questionId)) {
      _questionsState[questionId] = DragAndDropQuestionState();
    }
    return _questionsState[questionId]!;
  }

  // Initialize options for a specific question
  void initialize(int questionId, List<String> images) {
    final state = getQuestionState(questionId);
    if (!state.isInitialized) {
      state.remainingImages = Set.from(images);
      state.isInitialized = true;
      notifyListeners();
    }
  }

  // Add a match for a specific question
  void addMatch(int questionId, String imageUrl, String category) {
    final state = getQuestionState(questionId);
    state.userMatches.removeWhere((key, value) => value == category);
    state.userMatches[imageUrl] = category;
    state.remainingImages.remove(imageUrl);
    state.updateSelectedAnswers();
    notifyListeners();
  }

  // Remove a match for a specific question
  void removeMatch(int questionId, String imageUrl) {
    final state = getQuestionState(questionId);
    state.userMatches.remove(imageUrl);
    state.remainingImages.add(imageUrl);
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
