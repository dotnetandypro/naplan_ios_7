import 'package:flutter/material.dart';

// Provider for Word Matching Questions
class WordMatchingState extends ChangeNotifier {
  Map<String, String> userMatches = {}; // Stores matched words
  Set<String> remainingOptions = {}; // Available options
  bool isInitialized = false;
  List<String> selectedAnswers = []; // Formatted answers for submission

  void initialize(List<String> options) {
    if (!isInitialized) {
      remainingOptions = Set.from(options);
      isInitialized = true;
      notifyListeners();
    }
  }

  void addMatch(String option, String category) {
    userMatches.removeWhere((key, value) => value == category);
    userMatches[option] = category;
    remainingOptions.remove(option);
    _updateSelectedAnswers();
    notifyListeners();
  }

  void removeMatch(String option) {
    userMatches.remove(option);
    remainingOptions.add(option);
    _updateSelectedAnswers();
    notifyListeners();
  }

  // Convert user matches to formatted answers
  void _updateSelectedAnswers() {
    selectedAnswers = userMatches.entries
        .map((entry) => "${entry.value}:${entry.key}")
        .toList();
  }

  // Reset state
  void reset() {
    userMatches = {};
    remainingOptions = {};
    selectedAnswers = [];
    isInitialized = false;
    notifyListeners();
  }
}
