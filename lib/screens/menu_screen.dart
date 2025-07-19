import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'start_screen.dart';
import 'student_dashboard_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> studentUids = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchStudentUids();
  }

  Future<void> fetchStudentUids() async {
    try {
      final response = await ApiService.get('testpacks/users');

      if (response.statusCode == 200) {
        setState(() {
          studentUids = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load student UIDs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAPLAN Dashboard'),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Review All Questions Button
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  style: AppTheme.primaryButtonStyle().copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StartScreen(testId: "0"),
                      ),
                    );
                  },
                  icon: Icon(Icons.list_alt, size: 28),
                  label: Text(
                    'Review All Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // View Student Dashboard Section
              Text(
                'View Student Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16),

              // Student UIDs list
              Expanded(
                child: _buildStudentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
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
                fetchStudentUids();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (studentUids.isEmpty) {
      return Center(
        child: Text(
          'No students found',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: studentUids.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    studentUids[index].substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  'Student ID: ${studentUids[index]}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text('Click to view dashboard'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentDashboardScreen(uid: studentUids[index]),
                    ),
                  );
                },
              ),
              if (index < studentUids.length - 1)
                Divider(height: 1, indent: 70),
            ],
          );
        },
      ),
    );
  }
}
