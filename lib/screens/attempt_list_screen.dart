import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/request_settings.dart';
import '../models/attempt_models.dart';
import '../theme/app_theme.dart';
import 'start_screen.dart'; // Import for the "Retake Test" button
import 'exam_screen_review.dart'; // Import for the ExamScreenReview screen

class AttemptListScreen extends StatefulWidget {
  final String uid;
  final String testId;
  final Map<String, dynamic>? testDetails; // Add parameter for test details

  const AttemptListScreen({
    Key? key,
    required this.uid,
    required this.testId,
    this.testDetails, // Add to constructor
  }) : super(key: key);

  @override
  _AttemptListScreenState createState() => _AttemptListScreenState();
}

class _AttemptListScreenState extends State<AttemptListScreen> {
  List<AttemptListDto> attempts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAttempts();
  }

  Future<void> fetchAttempts() async {
    print("=============== FETCHING ATTEMPTS ===============");
    print("UID: ${widget.uid}");
    print("TestID: ${widget.testId}");

    try {
      final endpoint = 'test-submit/attempts/${widget.uid}/${widget.testId}';
      final url = Uri.parse('${RequestSettings.baseUrl}/$endpoint');
      print("API URL: $url");

      print("Making HTTP request...");
      final response = await http.get(
        url,
        headers: RequestSettings.getHeaders(),
      );

      print("Response status code: ${response.statusCode}");
      print("Response body length: ${response.body.length}");
      if (response.body.length < 1000) {
        print("Response body: ${response.body}");
      } else {
        print("Response body too large to print fully");
      }

      if (response.statusCode == 200) {
        print("Successfully received data, parsing JSON...");
        final List<dynamic> data = json.decode(response.body);
        print("Parsed ${data.length} attempts from response");

        setState(() {
          attempts = data.map((json) => AttemptListDto.fromJson(json)).toList();
          print("Created ${attempts.length} AttemptListDto objects");
          for (var attempt in attempts) {
            print(
                "Attempt ID: ${attempt.id}, Type: ${attempt.id.runtimeType}, Score: ${attempt.score}");
          }
          isLoading = false;
        });
      } else if (response.statusCode == 404 &&
          response.body.contains("No test attempts found")) {
        // This is an expected response when the user hasn't taken the test yet
        // Instead of showing an error, we'll just show the empty state
        print("No attempts found for this test - showing empty state UI");
        setState(() {
          attempts = []; // Empty list
          isLoading = false;
          error = null; // Make sure no error is shown
        });
      } else {
        print("Error response: ${response.statusCode}");
        print("Error body: ${response.body}");
        setState(() {
          error = 'Failed to load attempts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception in fetchAttempts: $e");
      print("Stack trace: ${StackTrace.current}");
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
    print("=============== FETCH ATTEMPTS COMPLETED ===============");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press to navigate back to category test list
      onWillPop: () async {
        // Return to CategoryTestListScreen
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Attempts'),
          backgroundColor: AppTheme.primaryColor,
          automaticallyImplyLeading: true, // Show the back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                fetchAttempts();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (attempts.isEmpty) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'You haven\'t completed this test yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Take the test to see your results and track your progress.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to start screen to take the test
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StartScreen(
                        testId: widget.testId,
                        uid: widget.uid,
                        testDetails: widget.testDetails,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.play_arrow),
                label: Text('Start Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Previous Attempts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),

          // Add Retake Test button in the middle
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to start screen to retake the test
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StartScreen(
                      testId: widget.testId,
                      uid: widget.uid,
                      testDetails:
                          widget.testDetails, // Pass testDetails to StartScreen
                    ),
                  ),
                );
              },
              icon: Icon(Icons.replay),
              label: Text('Retake Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attempt #${attempts.length - index}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(attempt.submittedTime),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 10),
                        _buildInfoRow(
                            'Score', '${attempt.score.toStringAsFixed(1)}%'),
                        _buildInfoRow('Correct Answers',
                            '${attempt.correctAnswers}/${attempt.totalQuestions}'),
                        _buildInfoRow(
                            'Time Taken', _formatTime(attempt.timeToTake)),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Extended debug prints
                              print(
                                  "==========================================");
                              print("VIEW DETAILS BUTTON PRESSED");
                              print("Attempt ID: ${attempt.id}");
                              print(
                                  "Attempt ID type: ${attempt.id.runtimeType}");
                              print("Attempt Score: ${attempt.score}");

                              try {
                                print(
                                    "About to navigate to ExamScreenReview...");

                                // Navigate to ExamScreenReview with attemptId
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      print("Inside MaterialPageRoute builder");
                                      print(
                                          "Converting attemptId: ${attempt.id} to string: ${attempt.id.toString()}");

                                      // Add more debugging before returning the widget
                                      final examWidget = ExamScreenReview(
                                        attemptId: attempt.id.toString(),
                                        uid: widget
                                            .uid, // Pass uid from AttemptListScreen
                                      );

                                      print(
                                          "ExamScreenReview widget created successfully");
                                      return examWidget;
                                    },
                                  ),
                                ).then((_) {
                                  // Add callback to check when navigation completes
                                  print("Navigation completed and returned");
                                }).catchError((error) {
                                  // Add error handling for the navigation itself
                                  print("Navigation error: $error");
                                });

                                print("Navigation push initiated");
                              } catch (e) {
                                print(
                                    "Exception caught in View Details button: $e");
                                print(
                                    "Exception stack trace: ${StackTrace.current}");

                                // Show error to user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error opening review: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              print(
                                  "==========================================");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Convert decimal minutes to a formatted time string (minutes:seconds)
  String _formatTime(double timeInMinutes) {
    int totalSeconds = (timeInMinutes * 60).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
