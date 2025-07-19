import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/exam_header.dart';
import '../widgets/question_card.dart';
import '../widgets/exam_navigation.dart';
import '../widgets/answer_options/answer_options.dart';
import '../models/question_model.dart';
import '../models/question_type.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'progress_summary_screen.dart';
import 'student_dashboard_screen.dart'; // Add import for StudentDashboardScreen

class ExamScreen extends StatefulWidget {
  final String? testId;
  final String? uid;
  final List<dynamic>? questionList;
  final int? durationInMinutes; // Add parameter for test duration
  final Map<String, dynamic>? testDetails; // Add parameter for test details
  final bool? isParent; // Add parameter for parent check

  const ExamScreen({
    Key? key,
    this.testId,
    this.uid,
    this.questionList,
    this.durationInMinutes, // Add to constructor
    this.testDetails, // Add to constructor
    this.isParent, // Add to constructor
  }) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentQuestionIndex = 0;
  int _timeLeft = 120;
  late Timer _timer;
  List<Question> _questions = [];
  List<dynamic> _selectedAnswers = [];
  List<dynamic> _convertedSelectedAnswers =
      []; // New variable to store converted answers
  List<bool> _flaggedQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _loadQuestions();
  }

  void _initializeTimer() {
    // Convert duration from minutes to seconds, default to 2 minutes if not provided
    _timeLeft = widget.durationInMinutes != null
        ? widget.durationInMinutes! * 60 // Convert minutes to seconds
        : 120; // Default 2 minutes

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        // Optionally auto-submit the exam when time is up
        // _submitExam();
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      List<dynamic> data = [];

      // First check if we have a question list passed from the previous screen
      if (widget.questionList != null && widget.questionList!.isNotEmpty) {
        print("Using question list passed from previous screen");
        data = widget.questionList!;
      }
      // Otherwise load questions based on testId or from local file
      else {
        try {
          final response = await ApiService.get('questions/all-questions');

          if (response.statusCode == 200) {
            data = json.decode(response.body);
            print("API call successful, got ${data.length} questions");
          } else {
            print("API call failed with status: ${response.statusCode}");
            throw Exception('Failed to load questions');
          }
        } catch (e) {
          print("API call failed, falling back to local questions file: $e");
          final String response =
              await rootBundle.loadString('assets/data/questions.json');
          data = json.decode(response);
          print("Loaded ${data.length} questions from local file");
        }
      }
      setState(() {
        _questions = data.map((json) => Question.fromJson(json)).toList();
        _selectedAnswers = List.generate(
          _questions.length,
          (index) {
            switch (_questions[index].type) {
              case QuestionType.multipleChoice:
              case QuestionType.gridToChoice:
              case QuestionType.multipleChoiceImage:
              case QuestionType.dragToOrder:
              case QuestionType.sentenceSelection:
              case QuestionType.selectionMultiple:
              case QuestionType.multipleTrueFalse:
              case QuestionType.wordMatching:
              case QuestionType.dragAndDropImages:
              case QuestionType.dragToChoice:
              case QuestionType.dropdownSelection:
              case QuestionType.fillTheBlank:
              case QuestionType.narrativeWriting:
              case QuestionType.persuasiveWriting:
                return <String>[];
              case QuestionType.dragToGroup:
                return <String, List<String>>{};
            }
          },
        );
        _flaggedQuestions = List.filled(_questions.length, false);
      });
    } catch (error) {
      print('Error loading questions: $error');
    }
  }

  void _toggleFlag() {
    setState(() {
      _flaggedQuestions[_currentQuestionIndex] =
          !_flaggedQuestions[_currentQuestionIndex];
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Print selected answers for debugging before navigating to the summary screen
        print("Selected answers before navigating to summary:");
        for (int i = 0; i < _selectedAnswers.length; i++) {
          print("Question ${i + 1}: ${_selectedAnswers[i]}");
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressSummaryScreen(
              questions: _questions,
              selectedAnswers: _selectedAnswers,
              flaggedQuestions: _flaggedQuestions,
              onQuestionSelected: (index) {
                Navigator.pop(context);
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              onSubmit: _submitExam,
              onBack: () {
                Navigator.pop(context);
              },
              isParent: widget.isParent ?? false, // Pass isParent parameter
            ),
          ),
        );
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    } else {
      // We're on the first question, go back to the start screen
      Navigator.of(context).pop();
    }
  }

  void _submitExam() {
    // Clear and populate the converted answers list
    _convertedSelectedAnswers = [];

    for (int i = 0; i < _questions.length; i++) {
      dynamic convertedAnswer = _selectedAnswers[i];

      // Convert dragToGroup answers from Map<String, List<String>> to List<String>
      if (_questions[i].type == QuestionType.dragToGroup &&
          _selectedAnswers[i] is Map<String, List<String>>) {
        Map<String, List<String>> groupMap = _selectedAnswers[i];
        List<String> convertedList = [];

        groupMap.forEach((category, options) {
          for (var option in options) {
            convertedList.add("$category:$option");
          }
        });

        convertedAnswer = convertedList;
      }

      _convertedSelectedAnswers.add(convertedAnswer);
    }

    // Prepare the submission payload
    Map<String, dynamic> payload = {
      "uid": widget.uid ?? "",
      "testId": int.tryParse(widget.testId ?? "0") ?? 0,
      "timeToTake": _calculateTimeToTake(),
      "questionSubmissions": _prepareQuestionSubmissions(),
    };

    // Print submission payload for debugging
    print("SUBMITTING EXAM:");
    print(json.encode(payload));

    // Submit to API
    _submitToApi(payload);
  }

  // Calculate time taken in minutes (as decimal)
  double _calculateTimeToTake() {
    int totalSeconds =
        (widget.durationInMinutes ?? 2) * 60; // Total time in seconds
    int secondsTaken = totalSeconds - _timeLeft; // Seconds used
    return secondsTaken / 60; // Convert to minutes as decimal
  }

  // Prepare question submissions in the format expected by the API
  List<Map<String, dynamic>> _prepareQuestionSubmissions() {
    List<Map<String, dynamic>> submissions = [];

    for (int i = 0; i < _questions.length; i++) {
      submissions.add({
        "questionId": _questions[i].id,
        "userAnswer": _convertedSelectedAnswers[i] is List
            ? _convertedSelectedAnswers[i]
            : <String>[],
        "isFlagged": _flaggedQuestions[i],
      });
    }

    return submissions;
  }

  // Make the API call to submit the exam
  Future<void> _submitToApi(Map<String, dynamic> payload) async {
    // Show a loading dialog with a spinner while submitting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Submitting your answers...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final response = await ApiService.post('test-submit', payload);

      // Close the loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Exam submitted successfully!");
        print("Response: ${response.body}");

        // Parse response to get score
        double? score;
        try {
          final responseData = json.decode(response.body);
          score = responseData['Score']?.toDouble();
        } catch (e) {
          print("Error parsing response for score: $e");
        }

        if (widget.uid != null && widget.testId != null) {
          // Show success popup before navigating
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text("Exam Completed"),
                ],
              ),
              content: Text(score != null
                  ? "Submitted successfully! Your score is ${score.toStringAsFixed(1)}%. View details in Attempt Details."
                  : "Submitted successfully! View details in Attempt Details."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate directly to StudentDashboardScreen instead of using named route
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => StudentDashboardScreen(
                          uid: widget.uid ?? "",
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: Text("Go to Dashboard"),
                ),
              ],
            ),
          );
        } else {
          // Show success dialog if uid or testId is missing
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text("Exam Completed"),
                ],
              ),
              content: Text(score != null
                  ? "Submitted successfully! Your score is ${score.toStringAsFixed(1)}%."
                  : "Submitted successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (widget.uid != null) {
                      // Return to student dashboard if uid is available
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/studentdashboard/${widget.uid}', (route) => false);
                    } else {
                      // Otherwise go to the menu
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        print("Failed to submit exam: ${response.statusCode}");
        print("Response: ${response.body}");

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Submission Failed"),
            content: Text(
                "There was a problem submitting your answers. Error: ${response.statusCode}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context).pop();

      print("Error submitting exam: $e");

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Connection Error"),
          content: Text("There was a problem connecting to the server: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Remove the unused _formatAnswer method

  void _saveAnswer(dynamic value) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = value;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Question questionData = _questions[_currentQuestionIndex];
    bool isFlagged = _flaggedQuestions[_currentQuestionIndex];
    bool isMobile = MediaQuery.of(context).size.width <= 800;
    // Check if there's any content to display in the description panel (text or images)
    bool hasDescription =
        questionData.description.isNotEmpty || questionData.image.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Timer and Question Index
            ExamHeader(
              timeLeft: _timeLeft,
              questionIndex: _currentQuestionIndex,
              totalQuestions: _questions.length,
              questions: _questions,
              selectedAnswers: _selectedAnswers,
              flaggedQuestions: _flaggedQuestions,
              onQuestionSelected: (index) {
                Navigator.pop(context);
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              onSubmit: _submitExam,
              isParent: widget.isParent ?? false, // Pass isParent parameter
            ),

            // ✅ Scrollable Content with Flag Button
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flag Button with improved styling
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _toggleFlag,
                        icon: Icon(
                          isFlagged ? Icons.flag : Icons.outlined_flag,
                          size: 20,
                        ),
                        label: Text(
                          isFlagged ? "Flagged" : "Flag Question",
                        ),
                        style: AppTheme.flagButtonStyle(isFlagged: isFlagged),
                      ),
                    ),

                    SizedBox(height: 10),

                    // ✅ Responsive Layout with 50-50 Split
                    isMobile || !hasDescription
                        ? Column(
                            children: [
                              if (hasDescription)
                                QuestionCard(question: questionData),
                              SizedBox(height: 16),
                              AnswerOptions(
                                key: ValueKey(
                                    "answer_options_${_currentQuestionIndex}"),
                                question: questionData,
                                selectedAnswer:
                                    _selectedAnswers[_currentQuestionIndex],
                                onAnswerSelected: _saveAnswer,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Left Side (Description) - 50%
                              Expanded(
                                flex: 1, // ✅ Set both to equal width
                                child: QuestionCard(question: questionData),
                              ),
                              SizedBox(width: 20),

                              // ✅ Right Side (Answer Options) - 50%
                              Expanded(
                                flex: 1, // ✅ Set both to equal width
                                child: AnswerOptions(
                                  key: ValueKey(
                                      "answer_options_${_currentQuestionIndex}"),
                                  question: questionData,
                                  selectedAnswer:
                                      _selectedAnswers[_currentQuestionIndex],
                                  onAnswerSelected: _saveAnswer,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            // ✅ Navigation Buttons
            ExamNavigation(
              onNext: _nextQuestion,
              onPrevious: _previousQuestion,
              isLastQuestion: _currentQuestionIndex == _questions.length - 1,
              showBack: true, // Always show the back button
              isFirstQuestion:
                  _currentQuestionIndex == 0, // Pass if it's the first question
            ),
          ],
        ),
      ),
    );
  }
}
