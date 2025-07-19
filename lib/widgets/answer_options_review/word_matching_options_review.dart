import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/word_matching_review_state_manager.dart';
import '../common/question_text_with_image.dart';
import '../common/dynamic_image.dart';
import '../common/convert_text.dart';

class WordMatchingOptionsReview extends StatefulWidget {
  final int questionId;
  final String questionText;
  final List<String> options;
  final List<String> categories;
  final Function(List<String>) onAnswerSelected;
  final String? questionTextImage;
  final String questionContext;

  const WordMatchingOptionsReview({
    Key? key,
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.categories,
    required this.onAnswerSelected,
    required this.questionContext,
    this.questionTextImage,
  }) : super(key: key);

  @override
  _WordMatchingOptionsStateReview createState() =>
      _WordMatchingOptionsStateReview();
}

class _WordMatchingOptionsStateReview extends State<WordMatchingOptionsReview> {
  String? draggedItem;
  Map<String, double> optionWidths = {};
  Map<String, double> categoryWidths = {};

  // Utility method to measure text width
  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width;
  }

  // Calculate flexible width for text with padding
  double _calculateFlexibleWidth(String text, TextStyle style,
      {double minWidth = 120, double maxWidth = 300}) {
    double textWidth = _measureTextWidth(text, style);
    double totalWidth = textWidth + 32; // Add padding (16px on each side)
    return math.max(minWidth, math.min(maxWidth, totalWidth));
  }

  // Calculate widths for all options and categories
  void _calculateItemWidths() {
    const TextStyle optionStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const TextStyle categoryStyle = TextStyle(fontSize: 18);

    // Calculate option widths
    for (String option in widget.options) {
      bool isImage = Uri.tryParse(option)?.hasAbsolutePath ?? false;
      if (isImage) {
        optionWidths[option] = 120; // Fixed width for images
      } else {
        optionWidths[option] = _calculateFlexibleWidth(option, optionStyle,
            minWidth: 120, maxWidth: 250);
      }
    }

    // Calculate category widths
    for (String category in widget.categories) {
      bool isImage = Uri.tryParse(category)?.hasAbsolutePath ?? false;
      if (isImage) {
        categoryWidths[category] = 200; // Fixed width for images
      } else {
        categoryWidths[category] = _calculateFlexibleWidth(
            category, categoryStyle,
            minWidth: 150, maxWidth: 350);
      }
    }
  }

  // Initialize the state manager with the provided selected answers
  void _initializeWithSelectedAnswers(
      WordMatchingReviewStateManager stateManager,
      List<String> selectedAnswers) {
    if (!stateManager.isQuestionInitialized(widget.questionId)) {
      // Parse the selected answers and populate the state
      for (String answer in selectedAnswers) {
        if (answer.isNotEmpty && answer.contains(':')) {
          List<String> parts = answer.split(':');
          if (parts.length == 2) {
            String category = parts[0];
            String option = parts[1];
            stateManager.addMatch(widget.questionId, option, category);
          }
        }
      }
      stateManager.markQuestionInitialized(widget.questionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<WordMatchingReviewStateManager>(context);
    final selectedAnswers = Provider.of<List<String>>(context);

    // Initialize the state with the provided selected answers
    _initializeWithSelectedAnswers(stateManager, selectedAnswers);

    final state = stateManager.getQuestionState(widget.questionId);

    // Calculate widths for all items
    _calculateItemWidths();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ConvertText(
            text: widget.questionContext,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),

        const SizedBox(height: 10),

        // Connection lines layer and matching items
        Stack(
          children: [
            // Connection lines
            CustomPaint(
              painter: ConnectionsPainter(
                connections: state.userMatches.entries.map((entry) {
                  final optionIndex = widget.options.indexOf(entry.key);
                  final categoryIndex = widget.categories.indexOf(entry.value);
                  return Connection(optionIndex, categoryIndex);
                }).toList(),
                optionWidths: optionWidths,
                categoryWidths: categoryWidths,
                options: widget.options,
                categories: widget.categories,
              ),
              size: Size(MediaQuery.of(context).size.width,
                  widget.categories.length * 60.0),
            ),

            // Items to match
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column (options)
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        widget.options.length,
                        (index) => _buildOptionItem(
                          context,
                          stateManager,
                          widget.options[index],
                          index,
                        ),
                      ),
                    ),
                  ),

                  // Right column (categories)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        widget.categories.length,
                        (index) => _buildCategoryItem(
                          context,
                          stateManager,
                          widget.categories[index],
                          index,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionItem(BuildContext context,
      WordMatchingReviewStateManager stateManager, String option, int index) {
    final state = stateManager.getQuestionState(widget.questionId);
    bool isMatched = state.userMatches.containsKey(option);
    bool isImage = Uri.tryParse(option)?.hasAbsolutePath ?? false;
    double itemWidth = optionWidths[option] ?? 120;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: itemWidth,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
              color: isMatched ? Colors.green : Colors.blue, width: 2),
          color: isMatched
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: _buildDragItem(option, isImage, itemWidth),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context,
      WordMatchingReviewStateManager stateManager, String category, int index) {
    final state = stateManager.getQuestionState(widget.questionId);
    bool isCategoryImage = Uri.tryParse(category)?.hasAbsolutePath ?? false;
    double itemWidth = categoryWidths[category] ?? 200;

    // Find if this category is matched
    bool isMatched = state.userMatches.values.contains(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: itemWidth,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
              color: isMatched ? Colors.green : Colors.green, width: 2),
          color: isMatched
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.lightGreen.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: isCategoryImage
              ? DynamicImage(imageUrl: category, maxWidth: 100)
              : ConvertText(
                  text: category,
                  textStyle: const TextStyle(fontSize: 18),
                ),
        ),
      ),
    );
  }

  Widget _buildDragItem(String item, [bool isImage = false, double? width]) {
    return Container(
      width: width ?? 170,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: isImage
          ? DynamicImage(imageUrl: item, maxWidth: 80)
          : ConvertText(
              text: item,
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}

class Connection {
  final int optionIndex;
  final int categoryIndex;

  Connection(this.optionIndex, this.categoryIndex);
}

class ConnectionsPainter extends CustomPainter {
  final List<Connection> connections;
  final Map<String, double> optionWidths;
  final Map<String, double> categoryWidths;
  final List<String> options;
  final List<String> categories;

  ConnectionsPainter({
    required this.connections,
    required this.optionWidths,
    required this.categoryWidths,
    required this.options,
    required this.categories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double itemHeight =
        60.0; // Height including padding (50px box + 10px padding)
    const double leftPadding = 20.0; // Horizontal padding from screen edge

    for (var connection in connections) {
      // Get the actual option string
      final String option = options[connection.optionIndex];

      // Get the widths for these specific items
      final double optionWidth = optionWidths[option] ?? 120;

      // Calculate Y positions - center of each box (25px from top of each 50px box)
      final double startY =
          (connection.optionIndex * itemHeight) + 30; // Center of option box
      final double endY = (connection.categoryIndex * itemHeight) +
          30; // Center of category box

      // Calculate X positions more accurately
      // Left column starts at leftPadding and takes 40% of available space
      final double availableWidth = size.width - (leftPadding * 2);
      final double leftColumnWidth = availableWidth * 0.4;

      // Start X: right edge of the option box (left padding + option width)
      final double startX = leftPadding + optionWidth;

      // End X: left edge of the category box (start of right column)
      final double rightColumnStart = leftPadding + leftColumnWidth;
      final double endX = rightColumnStart;

      // Only draw line if there's space between the columns
      if (startX < endX) {
        // Create a smooth curved path from right edge of option to left edge of category
        final path = Path();
        path.moveTo(startX, startY);

        // Calculate control points for a smooth curve
        final double horizontalDistance = endX - startX;
        final double controlPoint1X = startX + (horizontalDistance * 0.3);
        final double controlPoint2X = endX - (horizontalDistance * 0.3);

        // Draw bezier curve
        path.cubicTo(controlPoint1X, startY, controlPoint2X, endY, endX, endY);

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
