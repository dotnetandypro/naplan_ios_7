import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'category_test_list_screen.dart'; // Import the new screen
import '../widgets/webview_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String? uid;
  final bool showLogoutButton;

  const StudentDashboardScreen({
    Key? key,
    this.uid,
    this.showLogoutButton = false,
  }) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? dashboardData;
  String? currentUid;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    initializeUid();
  }

  /// Generate a device-based persistent UID
  Future<String> _generateDeviceBasedUid() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceIdentifier = '';

      if (kIsWeb) {
        // For web, use browser info
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceIdentifier =
            '${webInfo.browserName}_${webInfo.platform}_${webInfo.userAgent?.hashCode ?? 0}';
      } else if (Platform.isAndroid) {
        // For Android, use device ID and model
        final androidInfo = await deviceInfo.androidInfo;
        deviceIdentifier =
            '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}';
      } else if (Platform.isIOS) {
        // For iOS, use identifierForVendor and model
        final iosInfo = await deviceInfo.iosInfo;
        deviceIdentifier =
            '${iosInfo.identifierForVendor ?? 'unknown'}_${iosInfo.model}_${iosInfo.systemName}';
      } else {
        // Fallback for other platforms
        deviceIdentifier =
            'unknown_platform_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Create a hash of the device identifier to make it more uniform
      final bytes = utf8.encode(deviceIdentifier);
      final digest = sha256.convert(bytes);

      // Convert to a UUID-like format
      final hashString = digest.toString();
      final uuid =
          '${hashString.substring(0, 8)}-${hashString.substring(8, 12)}-${hashString.substring(12, 16)}-${hashString.substring(16, 20)}-${hashString.substring(20, 32)}';

      return uuid;
    } catch (e) {
      // Fallback to regular UUID if device info fails
      return const Uuid().v4();
    }
  }

  Future<void> initializeUid() async {
    try {
      String? uid = widget.uid;

      if (uid == null) {
        // Try to get UID from secure storage
        uid = await _secureStorage.read(key: 'student_uid');

        if (uid == null) {
          // Generate device-based persistent UID
          uid = await _generateDeviceBasedUid();

          // Call API to assign test pack
          final assignResponse = await ApiService.post('testpacks/assign', {
            "Uid": uid,
            "TestPackId": 16,
            "AssignedDate": DateTime.now().toIso8601String(),
          });

          if (assignResponse.statusCode == 200 ||
              assignResponse.statusCode == 201) {
            // Save UID to secure storage
            await _secureStorage.write(key: 'student_uid', value: uid);
          } else {
            String errorBody = '';
            try {
              errorBody = assignResponse.body;
            } catch (e) {
              errorBody = 'Unable to read response body';
            }

            setState(() {
              error =
                  'Failed to assign test pack for UID: $uid\n'
                  'Status Code: ${assignResponse.statusCode}\n'
                  'Response: $errorBody';
              isLoading = false;
            });
            return;
          }
        }
      }

      setState(() {
        currentUid = uid;
      });

      fetchStudentDashboard();
    } catch (e) {
      setState(() {
        error =
            'Error initializing student with UID: ${currentUid ?? widget.uid ?? 'null'}\n'
            'Error details: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchStudentDashboard() async {
    if (currentUid == null) {
      setState(() {
        error = 'Student UID not available';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.get('student/$currentUid');

      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load dashboard: ${response.statusCode}';
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

  String getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'conventionsoflanguage':
        return '📝';
      case 'reading':
        return '📚';
      case 'writing':
        return '✏️';
      case 'numeracy':
        return '🔢';
      default:
        return '📊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NAPLAN Year 7 Online Test'),
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
        child: Column(
          children: [
            // Terms and Privacy links at the top
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
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
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: 1,
                    color: Colors.grey[400],
                    margin: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            url: 'https://aussieeduhub.com.au/privacy-policy',
                            title: 'Privacy Policy',
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(child: _buildContent()),
          ],
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
                fetchStudentDashboard();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (dashboardData == null) {
      return Center(
        child: Text(
          'No data available for this student',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          SizedBox(height: 24),
          Text(
            'Category Performance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ..._buildCategoryCards(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Student photo/avatar moved to left side
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withOpacity(0.1),
                    border: Border.all(color: AppTheme.accentColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: SvgPicture.asset(
                        'assets/icon/avatar_icon.svg',
                        width: 60,
                        height: 60,
                        // Removed colorFilter to show original SVG colors
                      ),
                    ),
                  ),
                ),

                // Stats column - right side of the avatar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student ID at the top
                      SizedBox(height: 16),
                      // Stats in a row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            title: 'Completed Tests',
                            value: '${dashboardData!['TotalCompletedTest']}',
                            icon: Icons.assignment_turned_in,
                          ),
                          _buildStatItem(
                            title: 'Average Score',
                            value:
                                '${(dashboardData!['AverageScore'] as num).toStringAsFixed(1)}%',
                            icon: Icons.analytics,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryCards() {
    final categoryDetails = List<Map<String, dynamic>>.from(
      dashboardData!['CategoryDetails'] ?? [],
    );

    if (categoryDetails.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'No category details available',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ];
    }

    // Define a list of card colors - based on categories
    final Map<String, Color> categoryColors = {
      'conventionsoflanguage': Color(0xFF8E5DCF), // Purple
      'reading': Color(0xFF4285F4), // Blue
      'writing': Color(0xFF34A853), // Green
      'numeracy': Color(0xFFFBBC05), // Yellow/Orange
    };

    // Define category icons
    final Map<String, IconData> categoryIcons = {
      'conventionsoflanguage': Icons.spellcheck,
      'reading': Icons.menu_book,
      'writing': Icons.edit,
      'numeracy': Icons.calculate,
    };

    // Convert the category list into a grid layout
    return [
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500, // Much wider maximum width
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio:
              1.8, // Wider aspect ratio to make cards horizontal rectangles
        ),
        itemCount: categoryDetails.length,
        itemBuilder: (context, index) {
          final category = categoryDetails[index];
          final yearLevel = category['YearLevel'];
          final categoryName = category['CategoryName'];
          final numberOfTests = category['NumberOfTest'];
          final completedTests = category['NumberOfCompletedTest'];
          final averageScore = category['AverageScore'];

          // Get color based on category name (lowercase) or default to purple
          final cardColor =
              categoryColors[categoryName.toLowerCase()] ?? Color(0xFF8E5DCF);

          // Get icon for the category or default to assessment icon
          final categoryIcon =
              categoryIcons[categoryName.toLowerCase()] ?? Icons.assessment;

          // Determine brighter color for the bottom section
          final lighterCardColor = HSLColor.fromColor(cardColor)
              .withLightness(
                (HSLColor.fromColor(cardColor).lightness + 0.1).clamp(0.0, 1.0),
              )
              .toColor();

          return MouseRegion(
            cursor: SystemMouseCursors
                .click, // Change cursor to hand/pointer on hover
            child: GestureDetector(
              onTap: () {
                // Navigate to the category test list screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryTestListScreen(
                      categoryData: category,
                      studentUid: currentUid ?? '',
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
                child: Row(
                  // Changed from Column to Row to make a horizontal layout
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left section (dark color)
                    Container(
                      color: cardColor,
                      width: 140, // Fixed width for the left section
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              categoryIcon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Category name and year level
                          Text(
                            'Year $yearLevel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Modified to better handle long category names
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _formatCategoryName(categoryName),
                          ),
                        ],
                      ),
                    ),

                    // Right section (lighter color)
                    Expanded(
                      child: Container(
                        color: lighterCardColor,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Completion text
                            Text(
                              '$completedTests/$numberOfTests Tests Complete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 6),

                            // Slider progress indicator
                            Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    children: [
                                      // Filled portion - using LayoutBuilder to get exact width
                                      if (numberOfTests > 0)
                                        Container(
                                          width:
                                              constraints.maxWidth *
                                              (completedTests / numberOfTests),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // Average score
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${(averageScore as num).toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'AVG',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  // This method can be uncommented if needed in the future
  /*
  Widget _buildProgressBar(int completed, int total) {
    double progress = total > 0 ? completed / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 12,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          borderRadius: BorderRadius.circular(6),
        ),
        SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% completed',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
  */

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    // Check if screen width is less than 600px (phone display)
    final isPhone = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Icon(icon, size: 36, color: AppTheme.accentColor),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isPhone
                ? 28
                : 24, // Slightly larger on phones for better readability
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        // Only show title text if not on a phone
        if (!isPhone) ...[
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ],
    );
  }

  // This method can be uncommented if needed in the future
  /*
  Widget _buildCategoryStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  */

  List<Widget> _formatCategoryName(String categoryName) {
    // Create a user-friendly display name
    String displayName = categoryName;

    // Handle specific long category names
    if (categoryName.toLowerCase() == 'conventionsoflanguage') {
      displayName = 'CONVENTIONS OF LANGUAGE';
    } else {
      // For other categories, convert camelCase or lowercase to display format
      displayName = categoryName
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match[1]} ${match[2]}',
          ) // Split camelCase
          .toUpperCase();
    }

    // For excessively long words, break them up by adding a line break
    List<String> words = displayName.split(' ');
    List<Widget> result = [];

    for (int i = 0; i < words.length; i++) {
      result.add(
        Text(
          words[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return result;
  }
}
