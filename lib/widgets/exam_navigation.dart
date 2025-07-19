import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExamNavigation extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isLastQuestion;
  final bool showBack;
  final bool isFirstQuestion;

  const ExamNavigation({
    required this.onNext,
    required this.onPrevious,
    required this.isLastQuestion,
    required this.showBack,
    this.isFirstQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (showBack)
            ElevatedButton(
              onPressed: onPrevious,
              child: Icon(Icons.arrow_back,
                  size: 32,
                  color: isFirstQuestion
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white),
              style: AppTheme.outlineButtonStyle(
                  color: isFirstQuestion
                      ? AppTheme.primaryColor.withOpacity(0.7)
                      : AppTheme.primaryColor),
            ),
          Spacer(),
          ElevatedButton(
            onPressed: onNext,
            child: Icon(
                isLastQuestion
                    ? Icons.assessment_outlined
                    : Icons.arrow_forward,
                size: 32,
                color: Colors.white),
            style: AppTheme.primaryButtonStyle(),
          ),
        ],
      ),
    );
  }
}
