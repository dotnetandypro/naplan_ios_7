import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/request_settings.dart';
import '../theme/app_theme.dart';
import '../models/question_model.dart';
import 'start_screen.dart';

class PackageTestListScreen extends StatefulWidget {
  final String uid;
  final String testPackId;

  const PackageTestListScreen({
    Key? key,
    required this.uid,
    required this.testPackId,
  }) : super(key: key);

  @override
  _PackageTestListScreenState createState() => _PackageTestListScreenState();
}

class _PackageTestListScreenState extends State<PackageTestListScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _testPackData;

  @override
  void initState() {
    super.initState();
    _fetchTestPackData();
  }

  Future<void> _fetchTestPackData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final endpoint = 'testpacks/${widget.testPackId}/${widget.uid}';
      final url = Uri.parse('${RequestSettings.baseUrl}/$endpoint');
      final response = await http.get(
        url,
        headers: RequestSettings.getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _testPackData = jsonData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load test pack data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getCategoryDisplayName(String categoryCode) {
    switch (categoryCode) {
      case 'conventionsOfLanguage':
        return 'Conventions of Language';
      case 'numeracy':
        return 'Numeracy';
      case 'reading':
        return 'Reading';
      case 'writing':
        return 'Writing';
      case 'naplanStyle':
        return 'NAPLAN Style';
      default:
        return categoryCode;
    }
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    final testId = test['Id'].toString();
    final title = test['Title'] ?? 'Untitled Test';
    final description = test['Description'] ?? '';
    final timeInMinutes = test['TimeInMinutes'] ?? 0;
    final numberOfQuestions = test['NumberOfQuestions'] ?? 0;
    final category = test['Category'] ?? '';
    final yearLevel = test['YearLevel'] ?? '';
    final testLevel = test['TestLevel'] ?? 'standard';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // Test info section (takes most of the space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Description and metadata in a single line
                  Text(
                    '$description • ${_getCategoryDisplayName(category)} • $timeInMinutes mins • $numberOfQuestions questions',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Button at the end of the line
            SizedBox(width: 12.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to StartScreen with isParent set to true
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StartScreen(
                      testId: testId,
                      uid: widget.uid,
                      testDetails: test,
                      isParent: true, // Set isParent to true
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                minimumSize: Size(90, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: const Text('View Test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_testPackData != null ? _testPackData!['Title'] : 'Test Pack'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_testPackData == null) {
      return const Center(child: Text('No data available'));
    }

    final List<dynamic> tests = _testPackData!['Tests'] ?? [];

    // Sort tests by title
    tests.sort((a, b) => (a['Title'] ?? '').compareTo(b['Title'] ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Test Pack Info Section
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Text(
                _testPackData!['Description'] ?? '',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                      Icons.book, '${_testPackData!['TotalTests']} Tests'),
                  _buildInfoItem(
                      Icons.category,
                      _getCategoryDisplayName(
                          _testPackData!['Category'] ?? '')),
                  _buildInfoItem(
                      Icons.school, 'Year ${_testPackData!['Level']}'),
                ],
              ),
            ],
          ),
        ),

        // Tests List Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Available Tests',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),

        // Tests List
        Expanded(
          child: tests.isEmpty
              ? const Center(child: Text('No tests available in this package'))
              : ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    return _buildTestCard(tests[index]);
                  },
                ),
        ),
      ],
    );
  }
}
