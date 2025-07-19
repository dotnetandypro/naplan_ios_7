import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/aussie_edu_hub_logo.dart';
import '../widgets/webview_screen.dart';
import '../services/auth_service.dart';
import 'student_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showOnlyOnMobile;

  const LoginScreen({
    Key? key,
    this.showOnlyOnMobile = true,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return 24; // Very small screens (iPhone SE)
    } else if (screenWidth < 400) {
      return 28; // Small screens (iPhone 12 mini)
    } else if (screenWidth < 500) {
      return 32; // Medium screens (iPhone 12)
    } else {
      return 40; // Large screens (iPad)
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://aussieeduhub.com.au/api/students/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY':
              'XCrossAPIkeyLocalhost', // Using the same API key as in RequestSettings
        },
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['student'] != null && data['student']['ulid'] != null) {
          String uid = data['student']['ulid'];

          // Save user ID for persistence
          await AuthService.saveUserId(uid);

          // Navigate to StudentDashboardScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => StudentDashboardScreen(
                uid: uid,
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid response from server';
            _isLoading = false;
          });
        }
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'Failed to login. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if running on mobile platforms
    // Note: We'll keep this for future mobile-specific logic
    // bool isMobilePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    // If we're on web and showOnlyOnMobile is true, don't show login screen
    if (widget.showOnlyOnMobile && kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AussieEduHubLogo(fontSize: 36, showSubtitle: true),
              SizedBox(height: 40),
              Text(
                'Please use direct URL to access NAPLAN tests.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Need help? Contact support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/nom_nom.jpg'),
              opacity: 0.05,
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo with shadow effect - responsive sizing
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: AussieEduHubLogo(
                                fontSize: _getResponsiveFontSize(context),
                                showSubtitle: true,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Username field with animated label
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                floatingLabelStyle: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimaryColor,
                              ),
                              cursorColor: AppTheme.primaryColor,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password field with animated label
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                floatingLabelStyle: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimaryColor,
                              ),
                              cursorColor: AppTheme.primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Account creation info
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Need an account?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your parent needs to create an account for you and assign you a test package from the parent dashboard on our website https://aussieeduhub.com.au',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Error message with animation
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: _errorMessage != null ? 70 : 0,
                              margin: EdgeInsets.only(
                                  top: _errorMessage != null ? 20 : 0),
                              child: _errorMessage != null
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[700],
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(
                                                color: Colors.red[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                            ),

                            const SizedBox(height: 30),

                            // Login button with gradient
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.6),
                                  elevation: 3,
                                  shadowColor:
                                      AppTheme.primaryColor.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: _isLoading
                                        ? null
                                        : LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              Color(0xFF536DFE), // Lighter blue
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Terms and Privacy links
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => WebViewScreen(
                                              url:
                                                  'https://aussieeduhub.com.au/terms-and-conditions',
                                              title: 'Terms & Conditions',
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      child: Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppTheme.primaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 14,
                                    width: 1,
                                    color: Colors.grey[400],
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => WebViewScreen(
                                              url:
                                                  'https://aussieeduhub.com.au/privacy-policy',
                                              title: 'Privacy Policy',
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      child: Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppTheme.primaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Version number
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
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
            ),
          ),
        ));
  }
}
