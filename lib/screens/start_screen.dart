import 'package:flutter/material.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/question_model.dart';
import 'exam_screen.dart';

class StartScreen extends StatefulWidget {
  final String? testId;
  final Map<String, dynamic>? testDetails;
  final String? uid;
  final bool? isParent;

  const StartScreen({
    Key? key,
    this.testId,
    this.testDetails,
    this.uid,
    this.isParent,
  }) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<dynamic>? _questionList;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.testId != null && widget.uid != null) {
      _fetchQuestions();
    }
  }

  Future<void> _fetchQuestions() async {
    if (widget.testId == null || widget.uid == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
          "[Debug] Fetching questions for testId: ${widget.testId}, uid: ${widget.uid}");

      // Fetch questions for the specific test and user
      final response =
          await ApiService.get('tests/${widget.testId}/${widget.uid}');

      print("[Debug] API response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            "[Debug] API response: ${data.runtimeType} - ${data is Map ? 'Is Map' : 'Not Map'}");

        setState(() {
          // Extract the QuestionList from the response data
          if (data is Map && data.containsKey("QuestionList")) {
            _questionList = data["QuestionList"];
            print(
                "[Debug] Found QuestionList with ${_questionList?.length ?? 0} questions");
          } else {
            _errorMessage = 'Invalid response format: QuestionList not found';
            print(
                "[Debug] QuestionList not found in response. Keys: ${data is Map ? data.keys.toList() : 'Not a Map'}");
          }
          _isLoading = false;
        });
      } else {
        print("API call failed with status: ${response.statusCode}");
        setState(() {
          _errorMessage = 'Failed to load test questions. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use provided test details if available, otherwise use placeholder data
    final Map<String, dynamic> details = widget.testDetails ??
        {
          'name': 'Year 9 Mathematics',
          'questionCount': 42,
          'duration': '60 minutes',
          'category': 'Mathematics',
          'level': 'Year 9',
        };

    // Format test details for display
    final displayDetails = {
      'name': details['Title'] ?? details['name'] ?? 'Unknown',
      'questionCount':
          details['NumberOfQuestions'] ?? details['questionCount'] ?? 0,
      'duration': details['TimeInMinutes'] != null
          ? '${details['TimeInMinutes']} minutes'
          : details['duration'] ?? 'Unknown',
      'category': details['Category'] ?? details['category'] ?? 'Unknown',
      'level': details['YearLevel'] != null
          ? 'Year ${details['YearLevel']}'
          : details['level'] ?? 'Unknown',
      'description': details['Description'] ?? '',
      'testLevel': details['TestLevel'] ?? 'standard',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('NAPLAN Test'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          image: DecorationImage(
            image: AssetImage('assets/images/nom_nom.jpg'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 5,
              margin: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 450 ? 20 : 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width > 650
                    ? 600
                    : MediaQuery.of(context).size.width - 40,
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width > 600 ? 30 : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Test Information',
                        style: MediaQuery.of(context).size.width > 450
                            ? Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                )
                            : Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width > 450 ? 30 : 20),
                    _buildInfoRow(context, 'Test Name',
                        displayDetails['name']?.toString() ?? 'Unknown'),
                    _buildInfoRow(context, 'Number of Questions',
                        '${displayDetails['questionCount']} questions'),
                    _buildInfoRow(context, 'Duration',
                        displayDetails['duration']?.toString() ?? 'Unknown'),
                    _buildInfoRow(context, 'Category',
                        displayDetails['category']?.toString() ?? 'Unknown'),
                    _buildInfoRow(context, 'Level',
                        displayDetails['level']?.toString() ?? 'Unknown'),
                    // if (displayDetails['description'].toString().isNotEmpty)
                    //   _buildInfoRow(context, 'Description',
                    //       displayDetails['description'].toString()),
                    if (displayDetails['testLevel'].toString().isNotEmpty)
                      _buildInfoRow(
                          context,
                          'Difficulty',
                          _formatTestLevel(
                              displayDetails['testLevel'].toString())),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width > 450 ? 40 : 25),
                    // if (testId != null)
                    //   Center(
                    //     child: Text(
                    //       'Test ID: $testId',
                    //       style:
                    //           Theme.of(context).textTheme.bodySmall?.copyWith(
                    //                 fontStyle: FontStyle.italic,
                    //               ),
                    //     ),
                    //   ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width > 450 ? 20 : 15),
                    // Improved START TEST button with better mobile web compatibility
                    Center(
                      child: _isLoading
                          ? Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Loading test questions...',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : _errorMessage != null
                              ? Column(
                                  children: [
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _fetchQuestions,
                                      child: Text('Try Again'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width > 400
                                      ? 200
                                      : double.infinity,
                                  height: 50,
                                  child: Material(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                    elevation: 3,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        // Extract duration from test details
                                        int durationInMinutes = 0;
                                        if (widget.testDetails != null &&
                                            widget.testDetails![
                                                    'TimeInMinutes'] !=
                                                null) {
                                          durationInMinutes = widget
                                              .testDetails!['TimeInMinutes'];
                                        } else if (details['TimeInMinutes'] !=
                                            null) {
                                          durationInMinutes =
                                              details['TimeInMinutes'];
                                        } else {
                                          // Default duration if not found
                                          durationInMinutes = 15;
                                        }

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ExamScreen(
                                              testId: widget.testId,
                                              uid: widget.uid,
                                              durationInMinutes:
                                                  durationInMinutes,
                                              testDetails: widget.testDetails,
                                              isParent: widget.isParent,
                                              questionList: _questionList,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'START TEST',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 450;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: isWideScreen
          ? Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width > 600 ? 180 : 120,
                  child: Text(
                    label + ':',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label + ':',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
              ],
            ),
    );
  }

  String _formatTestLevel(String testLevel) {
    switch (testLevel.toLowerCase()) {
      case 'standard':
        return 'Standard';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return testLevel;
    }
  }
}
