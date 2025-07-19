import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart'; // Import for HTML rendering
import 'package:webview_flutter/webview_flutter.dart'; // Import for WebView
import '../services/request_settings.dart';
import 'package:provider/provider.dart';
import '../widgets/exam_header_review.dart';
import '../widgets/question_card.dart';
import '../widgets/exam_navigation.dart';
import '../widgets/answer_options_review/answer_options_review.dart';
import '../models/question_model.dart';
import '../models/question_type.dart';
import '../theme/app_theme.dart';
import '../providers/word_matching_review_state_manager.dart'; // Import for word matching review

class ExamScreenReview extends StatefulWidget {
  final String attemptId; // Changed to accept attemptId parameter
  final String uid; // Add uid parameter

  const ExamScreenReview({
    Key? key,
    required this.attemptId,
    required this.uid,
  }) : super(key: key);

  @override
  _ExamScreenReviewState createState() => _ExamScreenReviewState();
}

class _ExamScreenReviewState extends State<ExamScreenReview> {
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  List<dynamic> _selectedAnswers = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Added attempt details from API
  DateTime? _submittedTime;
  double _score = 0.0;
  double _timeToTake = 0.0;

  @override
  void initState() {
    super.initState();
    print("======== ExamScreenReview initState ========");
    print("Received attemptId: ${widget.attemptId}");
    _loadAttemptDetails();
  }

  Future<void> _loadAttemptDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print("Loading attempt details for ID: ${widget.attemptId}");

      // Make sure attemptId is not empty
      if (widget.attemptId.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid attempt ID: empty string';
          _isLoading = false;
        });
        return;
      }

      // Construct API URL with error checking
      final endpoint = 'test-submit/attempt-detail/${widget.attemptId}';
      final url = Uri.parse('${RequestSettings.baseUrl}/$endpoint');
      print("Making API request to: $url");

      final response =
          await http.get(url, headers: RequestSettings.getHeaders());

      print("API Response status code: ${response.statusCode}");
      print(
          "API Response body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("Decoded data keys: ${data.keys.toList()}");

        // Debug fields - Checking both uppercase and lowercase fields
        print("Id field: ${data['Id']}");
        print("SubmittedTime field: ${data['SubmittedTime']}");
        print("Score field: ${data['Score']}");
        print("TimeToTake field: ${data['TimeToTake']}");
        print("Questions field count: ${data['Questions']?.length ?? 'null'}");

        setState(() {
          try {
            // Use uppercase field names (PascalCase) as returned by the API
            // Safely parse submittedTime with null check
            _submittedTime = data['SubmittedTime'] != null
                ? DateTime.parse(data['SubmittedTime'])
                : DateTime.now();

            // Safely convert score and timeToTake to double
            _score = data['Score'] != null
                ? (data['Score'] is num
                    ? (data['Score'] as num).toDouble()
                    : 0.0)
                : 0.0;

            _timeToTake = data['TimeToTake'] != null
                ? (data['TimeToTake'] is num
                    ? (data['TimeToTake'] as num).toDouble()
                    : 0.0)
                : 0.0;

            // Check if we actually have question data in a form we can use
            bool hasUsableQuestions = false;
            if (data['Questions'] != null &&
                data['Questions'] is List &&
                data['Questions'].isNotEmpty) {
              try {
                _questions = (data['Questions'] as List)
                    .map((q) => Question.fromJson(q))
                    .toList();

                if (_questions.isNotEmpty) {
                  hasUsableQuestions = true;
                  // Initialize selected answers with the user's saved responses
                  _selectedAnswers = List.generate(
                    _questions.length,
                    (index) => _convertUserAnswer(
                        _questions[index].userAnswer, _questions[index].type),
                  );
                }
              } catch (e) {
                print("Error parsing questions: $e");
              }
            }

            // If we have no usable questions, check if we can find them elsewhere in the response
            if (!hasUsableQuestions) {
              // Create a placeholder question for debugging so the screen can load
              _questions = [
                Question(
                  id: 0,
                  level: 1,
                  groupId: 0,
                  subjectId: 0,
                  title: "Debug Title",
                  image: "",
                  description:
                      "The API response didn't contain properly formatted question data. Here's what we received:\n\n${json.encode(data)}",
                  questionText: "Debug Question - Response data format issue",
                  options: ["Option 1", "Option 2"],
                  correctAnswer: [],
                  type: QuestionType.multipleChoice,
                  categories: [],
                  isCorrect: false,
                  isFlagged: false,
                )
              ];
              _selectedAnswers = [[]];
            }

            _isLoading = false;
          } catch (parseError) {
            print("Error parsing response data: $parseError");
            _errorMessage = 'Error parsing response data: $parseError';
            _isLoading = false;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load attempt details: ${response.statusCode}';
        });
      }
    } catch (error) {
      print("Exception in _loadAttemptDetails: $error");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading attempt details: $error';
      });
    }
  }

  // Helper method to get empty answer structure based on question type
  dynamic _getEmptyAnswerForType(QuestionType type) {
    switch (type) {
      case QuestionType.dragToGroup:
        return <String, List<String>>{};
      default:
        return <String>[];
    }
  }

  // Convert userAnswer List<String> to appropriate type based on question type
  dynamic _convertUserAnswer(List<String>? userAnswer, QuestionType type) {
    print("DEBUG - _convertUserAnswer called");
    print("DEBUG - Question type: $type");
    print("DEBUG - Raw userAnswer: $userAnswer");

    if (userAnswer == null || userAnswer.isEmpty) {
      print("DEBUG - userAnswer is null or empty, returning empty structure");
      return _getEmptyAnswerForType(type);
    }

    // Add special debug for Word Matching questions
    if (type == QuestionType.wordMatching) {
      print("DEBUG - WORD MATCHING detected!");
      print(
          "DEBUG - Word Matching answer (keeping as List<String>): $userAnswer");
      // For wordMatching, just return the list as is since WordMatchingOptionsReview
      // already expects a List<String> format
      return userAnswer;
    }

    // For dragToGroup, convert from List<String> format ["key:value", "key:value2"...]
    // to Map<String, List<String>> format {key: [value, value2], key2: [value3]}
    if (type == QuestionType.dragToGroup) {
      Map<String, List<String>> result = {};

      for (String item in userAnswer) {
        // Skip empty or invalid items
        if (item.isEmpty || !item.contains(':')) continue;

        // Split by first colon
        int colonIndex = item.indexOf(':');
        String key = item.substring(0, colonIndex);
        String value = item.substring(colonIndex + 1);

        // Initialize the list for this key if it doesn't exist yet
        if (!result.containsKey(key)) {
          result[key] = [];
        }

        // Add the value to the list for this key
        result[key]!.add(value);
      }

      return result;
    }

    // For other question types, return the list as is
    final result = userAnswer;
    print("DEBUG - Converted userAnswer result: $result");
    return result;
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _saveAnswer(dynamic value) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Test Review"),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading attempt details...")
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Test Review"),
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(_errorMessage!),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAttemptDetails,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Test Review"),
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text("No questions found for this attempt."),
        ),
      );
    }

    final Question questionData = _questions[_currentQuestionIndex];
    bool isFlagged = questionData.isFlagged ?? false;
    bool isMobile = MediaQuery.of(context).size.width <= 800;
    // Check if there's any content to display in the description panel (text or image)
    bool hasDescription =
        questionData.description.isNotEmpty || questionData.image.isNotEmpty;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WordMatchingReviewStateManager(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Test Review"),
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Updated ExamHeaderReview with attempt details
              ExamHeaderReview(
                submittedTime: _submittedTime!.toIso8601String(),
                score: _score,
                timeToTake: _timeToTake,
                questions: _questions,
                currentQuestionIndex: _currentQuestionIndex,
                onQuestionSelected: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                uid: widget.uid, // Pass uid from ExamScreenReview
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flag indicator
                      if (isFlagged)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Chip(
                            label: Text("Flagged"),
                            backgroundColor: Colors.orange.shade100,
                            avatar: Icon(Icons.flag, color: Colors.orange),
                          ),
                        ),

                      SizedBox(height: 10),

                      // Question Result Indicator
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: questionData.isCorrect == true
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: questionData.isCorrect == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              questionData.isCorrect == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: questionData.isCorrect == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              questionData.isCorrect == true
                                  ? "Correct Answer"
                                  : "Incorrect Answer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: questionData.isCorrect == true
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Responsive Layout
                      isMobile || !hasDescription
                          ? Column(
                              children: [
                                if (hasDescription)
                                  QuestionCard(question: questionData),
                                SizedBox(height: 16),
                                AnswerOptionsReview(
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
                                // Left Side (Description)
                                Expanded(
                                  flex: 1,
                                  child: QuestionCard(question: questionData),
                                ),
                                SizedBox(width: 20),

                                // Right Side (Answer Options)
                                Expanded(
                                  flex: 1,
                                  child: AnswerOptionsReview(
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

                      // Answer Explanation section
                      SizedBox(height: 20),
                      AnswerExplanation(question: questionData),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              ExamNavigation(
                onNext: _nextQuestion,
                onPrevious: _previousQuestion,
                isLastQuestion: _currentQuestionIndex == _questions.length - 1,
                showBack: _currentQuestionIndex > 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create the AnswerExplanation widget for displaying correct answers and explanations
class AnswerExplanation extends StatelessWidget {
  final Question question;

  const AnswerExplanation({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  "Answer Explanation",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Conditional display: Writing Assessment or Correct Answer Section
          _buildAnswerOrAssessmentSection(),

          // Explanation Section
          if (question.answerExplanation != null &&
              question.answerExplanation!.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  // Add debugging for HTML content
                  Builder(
                    builder: (context) {
                      print(
                          "HTML answerExplanation content: ${question.answerExplanation}");
                      return Container();
                    },
                  ),
                  Html(
                    data: question.answerExplanation,
                    style: {
                      "p": Style(
                        fontSize: FontSize(18),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        lineHeight: LineHeight(1.5),
                        color: AppTheme.textPrimaryColor,
                      ),
                      "ul": Style(
                        margin: Margins.only(left: 20),
                        fontSize: FontSize(18),
                      ),
                      "li": Style(
                        fontSize: FontSize(18),
                        margin: Margins.only(bottom: 8),
                        color: AppTheme.textPrimaryColor,
                      ),
                      "strong": Style(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      "em": Style(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondaryColor,
                      ),
                    },
                    extensions: [
                      TagExtension(
                        tagsToExtend: {"img"},
                        builder: (extensionContext) {
                          final src = extensionContext.attributes['src'];
                          if (src != null) {
                            // Add debugging
                            print("HTML Image src attribute: $src");
                            final preparedUrl =
                                AnswerExplanation._prepareImageUrlStatic(src);
                            print("Prepared URL: $preparedUrl");

                            // Use WebView for mobile devices, Image.network for web
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 2),
                              child: _buildImageWidget(
                                preparedUrl.isNotEmpty ? preparedUrl : src,
                                300,
                                200,
                              ),
                            );
                          }
                          print("HTML Image tag has no src attribute");
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Conditional method to display either writing assessment or correct answer
  Widget _buildAnswerOrAssessmentSection() {
    if (question.type == QuestionType.narrativeWriting ||
        question.type == QuestionType.persuasiveWriting) {
      return _buildWritingAssessment();
    } else {
      return _buildCorrectAnswerSection();
    }
  }

  // Build writing assessment section for narrative and persuasive writing
  Widget _buildWritingAssessment() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Writing Assessment:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Assessment criteria grid
          _buildAssessmentCriteria(),

          // Feedback section
          if (question.feedback != null && question.feedback!.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              "Feedback:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                question.feedback!,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build assessment criteria grid
  Widget _buildAssessmentCriteria() {
    final criteria = [
      {'label': 'Audience', 'value': question.audience},
      {'label': 'Text Structure', 'value': question.textStructure},
      {'label': 'Ideas', 'value': question.ideas},
      {
        'label': question.type == QuestionType.narrativeWriting
            ? 'Character & Setting'
            : 'Persuasive Devices',
        'value': question.characterAndSettingOrPersuasiveDevices
      },
      {'label': 'Vocabulary', 'value': question.vocabulary},
      {'label': 'Cohesion', 'value': question.cohesion},
      {'label': 'Paragraphing', 'value': question.paragraphing},
      {'label': 'Sentence Structure', 'value': question.sentenceStructure},
      {'label': 'Punctuation', 'value': question.punctuation},
      {'label': 'Spelling', 'value': question.spelling},
    ];

    return Column(
      children: criteria.map((criterion) {
        return _buildCriterionRow(
            criterion['label'] as String, criterion['value'] as int?);
      }).toList(),
    );
  }

  // Build individual criterion row
  Widget _buildCriterionRow(String label, int? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getScoreColor(value).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _getScoreColor(value).withValues(alpha: 0.3)),
              ),
              child: Text(
                value?.toString() ?? 'Not Assessed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(value),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on score value
  Color _getScoreColor(int? value) {
    if (value == null) return Colors.grey;
    if (value >= 4) return Colors.green;
    if (value >= 3) return Colors.orange;
    return Colors.red;
  }

  // Build traditional correct answer section
  Widget _buildCorrectAnswerSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Correct Answer:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          _buildCorrectAnswer(),
        ],
      ),
    );
  }

  // Helper method to prepare image URL for loading
  String _prepareImageUrl(String url) {
    return AnswerExplanation._prepareImageUrlStatic(url);
  }

  // Helper method to build image widget with platform-specific fallbacks
  Widget _buildImageWidget(String imageUrl, double width, double height) {
    // Add debugging
    print("Building image widget for URL: $imageUrl");

    // Use WebView for mobile devices (iPad/iPhone/Android), Image.network for web
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildPlatformSpecificImage(imageUrl, width, height),
      ),
    );
  }

  Widget _buildPlatformSpecificImage(
      String imageUrl, double width, double height) {
    // Use WebView for mobile devices (iPad, iPhone, Android) and Image.network for web
    if (kIsWeb) {
      // For web browsers, use Image.network
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; AussieEduHub/1.0)',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Loading image...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Image.network failed for URL: $imageUrl");
          print("Error: $error");

          // Check if this is a URL configuration issue
          String errorMessage = 'Image failed to load';
          Color errorColor = Colors.red;

          if (imageUrl.contains('api.aussieeduhub.com')) {
            errorMessage = 'Server connection failed';
            errorColor = Colors.blue;
          } else if (imageUrl.isEmpty) {
            errorMessage = 'Invalid URL';
            errorColor = Colors.orange;
          } else if (error.toString().contains('network') ||
              error.toString().contains('connection')) {
            errorMessage = 'Network connection failed';
            errorColor = Colors.blue;
          }

          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: errorColor, size: 24),
                  SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: TextStyle(fontSize: 12, color: errorColor),
                    textAlign: TextAlign.center,
                  ),
                  if (imageUrl.length < 80) ...[
                    SizedBox(height: 4),
                    Text(
                      imageUrl,
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    } else {
      // For mobile devices (iPad, iPhone, Android), use WebView for better compatibility
      return _WebViewImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
      );
    }
  }

  // Static helper method for URL preparation
  static String _prepareImageUrlStatic(String url) {
    // Configuration: Update these with your actual server URLs
    // You may need to update these based on your deployment setup
    const String PRODUCTION_SERVER = 'https://api.aussieeduhub.com';

    // First try the URL as-is
    print("Original URL: $url");

    // Check if it's already a complete URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Handle localhost/nohost URLs that don't work on iPad
      String cleanedUrl = url.trim();

      // Replace problematic localhost/nohost URLs with proper external URLs
      if (cleanedUrl.contains('localhost') ||
          cleanedUrl.contains('nohost') ||
          cleanedUrl.contains('127.0.0.1')) {
        print(
            "Detected localhost/nohost URL, attempting to convert to external URL");

        // Extract the path portion of the URL
        Uri? originalUri;
        try {
          originalUri = Uri.parse(cleanedUrl);
        } catch (e) {
          print("Failed to parse URL: $cleanedUrl, error: $e");
          return ''; // Return empty to trigger error widget
        }

        String path = originalUri.path;
        String query = originalUri.query;
        String fullPath = path + (query.isNotEmpty ? '?$query' : '');

        print("Extracted path: $fullPath");

        // Try to determine the correct replacement server
        String replacementServer = PRODUCTION_SERVER;

        // If running in debug mode or development, you might want different logic here
        // For now, let's use a simple approach
        if (cleanedUrl.contains('localhost')) {
          // Replace localhost URLs - you might need to adjust the port
          if (cleanedUrl.contains('localhost:3000') ||
              cleanedUrl.contains('localhost:8080')) {
            replacementServer =
                PRODUCTION_SERVER; // or DEV_SERVER for development
          }
        } else if (cleanedUrl.contains('nohost')) {
          // nohost URLs typically need to be completely reconstructed
          // Extract just the filename/path portion
          final pathMatch = RegExp(r'nohost[^/]*/(.*)').firstMatch(cleanedUrl);
          if (pathMatch != null) {
            fullPath = '/' + pathMatch.group(1)!;
          } else {
            print("Could not extract path from nohost URL");
            return ''; // Return empty to trigger error widget with proper message
          }
          replacementServer = PRODUCTION_SERVER;
        }

        // Construct the new URL
        cleanedUrl = replacementServer + fullPath;
        print("Reconstructed URL: $cleanedUrl");

        // Validate the reconstructed URL
        try {
          Uri.parse(cleanedUrl);
        } catch (e) {
          print("Reconstructed URL is invalid: $cleanedUrl, error: $e");
          return '';
        }
      }

      // Encode special characters that might be problematic on iOS
      try {
        cleanedUrl = Uri.encodeFull(cleanedUrl);
      } catch (e) {
        print("Failed to encode URL: $cleanedUrl, error: $e");
        return '';
      }

      print("Final cleaned URL for iOS: $cleanedUrl");
      return cleanedUrl;
    }

    // If it's a relative URL, we might need to handle it differently
    print("Relative URL detected: $url");
    return url;
  }

  // Helper method to parse answer text and create widgets for text and images
  List<Widget> _parseAnswerWithImages(String answer) {
    List<Widget> widgets = [];

    // More flexible regex pattern to capture URLs with spaces and special characters
    // Look for patterns that start with http/https and contain image extensions
    final RegExp imagePattern = RegExp(
        r'https?://[^\n\r]*?\.(png|jpg|jpeg)(?:[^\w]|$)',
        multiLine: true,
        caseSensitive: false);

    int lastIndex = 0;
    final matches = imagePattern.allMatches(answer);

    for (final match in matches) {
      // Add text before the image (if any)
      if (match.start > lastIndex) {
        String textBefore = answer.substring(lastIndex, match.start);
        if (textBefore.isNotEmpty) {
          widgets.add(
            Text(
              textBefore,
              style: TextStyle(fontSize: 16),
            ),
          );
        }
      }

      // Add the image with improved URL handling
      String rawImageUrl = match.group(0)!;
      // Clean up the URL by removing trailing punctuation and whitespace
      String cleanedUrl =
          rawImageUrl.replaceAll(RegExp(r'[\s\.,;!?]+$'), '').trim();

      // Try different URL encoding approaches
      String finalImageUrl = _prepareImageUrl(cleanedUrl);

      widgets.add(
        Container(
          width: 120,
          height: 120,
          margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              finalImageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Show debugging info in console
                print("Failed to load image: $finalImageUrl");
                print("Original URL: $rawImageUrl");
                return Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.grey, size: 20),
                      Text('Error', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last image (if any)
    if (lastIndex < answer.length) {
      String textAfter = answer.substring(lastIndex);
      if (textAfter.isNotEmpty) {
        widgets.add(
          Text(
            textAfter,
            style: TextStyle(fontSize: 16),
          ),
        );
      }
    }

    // If no matches found, just return the original text
    if (widgets.isEmpty) {
      widgets.add(
        Text(
          answer,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCorrectAnswer() {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.multipleChoiceImage:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.correctAnswer
              .expand((answer) => _parseAnswerWithImages(answer))
              .toList(),
        );

      case QuestionType.sentenceSelection:
      case QuestionType.selectionMultiple:
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: question.correctAnswer
              .map((answer) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _parseAnswerWithImages(answer),
                    ),
                  ))
              .toList(),
        );

      case QuestionType.fillTheBlank:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.correctAnswer
              .expand((answer) => _parseAnswerWithImages(answer))
              .toList(),
        );

      case QuestionType.dragToGroup:
      case QuestionType.dragToChoice:
      case QuestionType.dragToOrder:
      case QuestionType.dragAndDropImages:
      case QuestionType.wordMatching:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: question.correctAnswer
              .map((answer) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _parseAnswerWithImages(answer),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case QuestionType.multipleTrueFalse:
      case QuestionType.dropdownSelection:
      case QuestionType.gridToChoice:
      default:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.correctAnswer
              .expand((answer) => _parseAnswerWithImages(answer))
              .toList(),
        );
    }
  }
}

// WebView-based image widget for mobile devices (iPad, iPhone, Android)
class _WebViewImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _WebViewImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<_WebViewImage> createState() => _WebViewImageState();
}

class _WebViewImageState extends State<_WebViewImage> {
  late WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      print('Initializing WebView for image: ${widget.imageUrl}');

      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('WebView started loading: $url');
              if (mounted) {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              print('WebView finished loading: $url');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView resource error: ${error.description}');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'Failed to load: ${error.description}';
                });
              }
            },
            onHttpError: (HttpResponseError error) {
              print('WebView HTTP error: ${error.response?.statusCode}');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP Error: ${error.response?.statusCode}';
                });
              }
            },
          ),
        );

      // Create HTML content that displays the image
      String htmlContent = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              padding: 0;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              background-color: #f5f5f5;
            }
            img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
              border-radius: 4px;
            }
          </style>
        </head>
        <body>
          <img src="${widget.imageUrl}" 
               alt="Image" 
               onerror="document.body.innerHTML='<div style=\\'text-align:center;color:#666;\\'>Image failed to load</div>'" />
        </body>
        </html>
      ''';

      controller.loadHtmlString(htmlContent);
    } catch (e) {
      print('Error initializing WebView: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to initialize: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (hasError) {
      // Show error state
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(height: 8),
              Text(
                errorMessage ?? 'Image failed to load',
                style: TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              if (widget.imageUrl.length < 80) ...[
                SizedBox(height: 4),
                Text(
                  widget.imageUrl,
                  style: TextStyle(fontSize: 8, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    } else if (isLoading) {
      // Show loading state
      return Container(
        color: Colors.grey.shade50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 8),
              Text(
                'Loading image...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show WebView
      return WebViewWidget(controller: controller);
    }
  }
}
