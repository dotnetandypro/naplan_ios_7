import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AussieEduHubLogo extends StatelessWidget {
  final double fontSize;
  final bool showSubtitle;

  const AussieEduHubLogo({
    Key? key,
    this.fontSize = 28.0,
    this.showSubtitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing with better iPhone support
    final screenWidth = MediaQuery.of(context).size.width;

    // More precise responsive sizing for different iPhone models
    double responsiveFontSize;
    if (screenWidth < 350) {
      responsiveFontSize = fontSize * 0.7; // iPhone SE (1st gen)
    } else if (screenWidth < 400) {
      responsiveFontSize =
          fontSize * 0.8; // iPhone SE (2nd/3rd gen), iPhone 12 mini
    } else if (screenWidth < 500) {
      responsiveFontSize = fontSize * 0.9; // iPhone 12/13/14 standard
    } else {
      responsiveFontSize = fontSize; // iPad and larger screens
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Aussie Edu ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: responsiveFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Hub',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: responsiveFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showSubtitle)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Student Portal',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: responsiveFontSize * 0.4,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }
}
