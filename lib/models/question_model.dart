import 'question_type.dart';
import 'dart:math';

class Question {
  //Left article is not compulsory
  final int id; // Question ID
  final int level; // Question level (level 1,2,3,4,5....12) compulsory
  final int groupId; // Question group (Naplan, Selective school,...) compulsory
  final int subjectId; // Geometry, number, reading, Algebra... compulsory
  final String title; // title for the left article
  final String image; // image for the left article
  final String description; // content of the left article
  final String questionText; // first part of the question compulsory
  final String? questionTextImage; // image for the first part of the question
  final String? questionContext; // second part of the question
  final List<String> options; //answer options for user to select
  final List<String> correctAnswer; //the correct answer for the question
  final QuestionType
      type; //  multipleChoice,sentenceSelection,selectionMultiple,multipleTrueFalse,wordMatching,dragAndDropImages,dropdownSelection,multipleChoiceImage,dragToOrder,dragToChoice,dragToGroup,gridToChoice,fillTheBlank
  final List<String> categories; //for question which need to category
  final int? gridSize; // grid size for gridToChoice question
  final List<String>? gridItems; // detail item for gridToChoice question
  final int? size; // use for dragToChoice and fillTheBlank question
  final String? audioUrl;
  final String? answerExplanation; // HTML content explaining the correct answer
  final List<String>? userAnswer; //the correct answer for the question
  final bool?
      isFlagged; // Question group (Naplan, Selective school,...) compulsory
  final bool?
      isCorrect; // Question group (Naplan, Selective school,...) compulsory

  // Writing assessment fields for narrativeWriting and persuasiveWriting
  final int? audience;
  final int? textStructure;
  final int? ideas;
  final int? characterAndSettingOrPersuasiveDevices;
  final int? vocabulary;
  final int? cohesion;
  final int? paragraphing;
  final int? sentenceStructure;
  final int? punctuation;
  final int? spelling;
  final String? feedback;

  Question(
      {required this.id,
      required this.level,
      required this.groupId,
      required this.subjectId,
      required this.title,
      required this.image,
      required this.description,
      required this.questionText,
      required this.options,
      required this.correctAnswer,
      required this.type,
      this.questionTextImage,
      this.questionContext,
      required this.categories,
      this.gridSize,
      this.gridItems,
      this.size,
      this.audioUrl,
      this.answerExplanation,
      this.userAnswer,
      this.isFlagged,
      this.isCorrect,
      this.audience,
      this.textStructure,
      this.ideas,
      this.characterAndSettingOrPersuasiveDevices,
      this.vocabulary,
      this.cohesion,
      this.paragraphing,
      this.sentenceStructure,
      this.punctuation,
      this.spelling,
      this.feedback});

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      // Convert potential null values to empty strings for String fields
      return Question(
          id: json['Id'] ?? json['id'] ?? 0,
          level: json['Level'] ?? json['level'] ?? 0,
          groupId: json['GroupId'] ?? json['groupId'] ?? 0,
          subjectId: json['SubjectId'] ?? json['subjectId'] ?? 0,
          title: json['Title'] ?? json['title'] ?? "",
          image: json['Image'] != null ? json['Image'] : (json['image'] ?? ""),
          description: json['Description'] != null
              ? json['Description']
              : (json['description'] ?? ""),
          audioUrl: json['AudioUrl'] != null
              ? json['AudioUrl']
              : (json['audioUrl'] ?? ""),
          questionText: json['QuestionText'] ?? json['questionText'] ?? "",
          options: json['Options'] != null
              ? List<String>.from(json['Options'])
              : (json['options'] != null
                  ? List<String>.from(json['options'])
                  : []),
          categories: json['Categories'] != null
              ? List<String>.from(json['Categories'])
              : (json['categories'] != null
                  ? List<String>.from(json['categories'])
                  : []),
          correctAnswer: json['CorrectAnswer'] != null
              ? List<String>.from(json['CorrectAnswer'])
              : (json['correctAnswer'] != null
                  ? List<String>.from(json['correctAnswer'])
                  : []),
          type: QuestionTypeExtension.fromString(
              json['Type'] ?? json['type'] ?? "multipleChoice"),
          questionContext: json['QuestionContext'] != null
              ? json['QuestionContext']
              : (json['questionContext'] ?? ""),
          questionTextImage: json['QuestionTextImage'] != null
              ? json['QuestionTextImage']
              : (json['questionTextImage'] ?? ""),
          gridSize: json['GridSize'] ?? json['gridSize'] ?? 5, // Default to 5x5
          gridItems: json['GridItems'] != null
              ? List<String>.from(json['GridItems'])
              : (json['gridItems'] != null
                  ? List<String>.from(json['gridItems'])
                  : []),
          size: json['Size'] ?? json['size'] ?? 1,
          answerExplanation: json['AnswerExplanation'] != null
              ? json['AnswerExplanation']
              : (json['answerExplanation'] != null
                  ? json['answerExplanation']
                  : ""),
          userAnswer: json['UserAnswer'] != null
              ? List<String>.from(json['UserAnswer'])
              : (json['userAnswer'] != null
                  ? List<String>.from(json['userAnswer'])
                  : []),
          isFlagged: json['IsFlagged'] != null
              ? json['IsFlagged']
              : (json['isFlagged'] != null
                  ? json['isFlagged']
                  : false), // Default to false
          isCorrect: json['IsCorrect'] != null
              ? json['IsCorrect']
              : (json['isCorrect'] != null
                  ? json['isCorrect']
                  : false), // Default to false
          // Writing assessment fields
          audience: json['Audience'] ?? json['audience'],
          textStructure: json['TextStructure'] ?? json['textStructure'],
          ideas: json['Ideas'] ?? json['ideas'],
          characterAndSettingOrPersuasiveDevices:
              json['CharacterAndSetting_OR_PersuasiveDevices'] ??
                  json['characterAndSetting_OR_PersuasiveDevices'],
          vocabulary: json['Vocabulary'] ?? json['vocabulary'],
          cohesion: json['Cohesion'] ?? json['cohesion'],
          paragraphing: json['Paragraphing'] ?? json['paragraphing'],
          sentenceStructure:
              json['SentenceStructure'] ?? json['sentenceStructure'],
          punctuation: json['Punctuation'] ?? json['punctuation'],
          spelling: json['Spelling'] ?? json['spelling'],
          feedback: json['Feedback'] ?? json['feedback']);
    } catch (e, stackTrace) {
      print("❌ Error in Question.fromJson: $e");
      print(
          "JSON data: ${json.toString().substring(0, min(200, json.toString().length))}...");
      print(stackTrace); // ✅ Prints the full error stack trace

      throw Exception("Invalid JSON structure: $e");
    }
  }

  // ✅ Convert to JSON (useful for saving)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'groupId': groupId,
      'subjectId': subjectId,
      'title': title,
      'image': image,
      'description': description,
      'questionText': questionText,
      'questionTextImage': questionTextImage,
      'options': options,
      'correctAnswer': correctAnswer,
      'type': type
          .toString()
          .split('.')
          .last, // ✅ Save only enum name (e.g., "multipleChoiceImage")
      'questionContext': questionContext,
      'categories': categories,
      'gridSize': gridSize,
      'gridItems': gridItems,
      'size': size,
      'audioUrl': audioUrl,
    };
  }
}
