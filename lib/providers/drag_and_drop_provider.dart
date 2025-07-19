import 'package:flutter/material.dart';

class DragAndDropState extends ChangeNotifier {
  Map<String, String> userMatches = {}; // Stores dropped images
  Set<String> remainingImages = {}; // ✅ Use Set to prevent duplicates
  bool isInitialized = false; // ✅ Prevents re-initialization issue
  List<String> selectedAnswers =
      []; // Stores answers in format ["string:string","string:string"]

  void initialize(List<String> images) {
    if (!isInitialized) {
      // ✅ Ensure state persists and doesn't reset
      remainingImages = Set.from(images);
      isInitialized = true;
      notifyListeners();
    }
  }

  void addMatch(String imageUrl, String category) {
    userMatches
        .removeWhere((key, value) => value == category); // ✅ Remove old image
    userMatches[imageUrl] = category;
    remainingImages.remove(imageUrl); // ✅ Remove from draggable list
    _updateSelectedAnswers();
    notifyListeners();
  }

  void removeMatch(String imageUrl) {
    userMatches.remove(imageUrl);
    remainingImages.add(imageUrl); // ✅ Put it back in draggable list
    _updateSelectedAnswers();
    notifyListeners();
  }

  // Convert userMatches map to a list of strings in format ["category:option", "category:option"]
  void _updateSelectedAnswers() {
    selectedAnswers = userMatches.entries
        .map((entry) => "${entry.value}:${entry.key}")
        .toList();
  }

  // Reset the state completely
  void reset() {
    userMatches = {};
    remainingImages = {};
    selectedAnswers = [];
    isInitialized = false;
    notifyListeners();
  }
}
