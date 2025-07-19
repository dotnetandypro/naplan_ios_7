import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';
import '../../theme/app_theme.dart';

class WritingOptions extends StatefulWidget {
  final String questionText;
  final String? questionTextImage;
  final String questionContext;
  final List<String> selectedAnswer;
  final Function(List<String>) onAnswerSelected;

  const WritingOptions({
    Key? key,
    required this.questionText,
    required this.questionContext,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.questionTextImage,
  }) : super(key: key);

  @override
  _WritingOptionsState createState() => _WritingOptionsState();
}

class _WritingOptionsState extends State<WritingOptions> {
  late TextEditingController _textController;
  TextAlign _textAlign = TextAlign.left;
  bool _isBold = false;
  bool _isItalic = false;
  double _fontSize = 28.0; // Updated default font size to 28

  @override
  void initState() {
    super.initState();
    // Get text from the list - use first item if available, otherwise empty string
    String initialText =
        widget.selectedAnswer.isNotEmpty ? widget.selectedAnswer[0] : "";
    _textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Store the entire essay as a single element in the list
    widget.onAnswerSelected([value]);
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  void _changeAlignment(TextAlign align) {
    setState(() {
      _textAlign = align;
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = _fontSize + 2.0;
      if (_fontSize > 32.0) _fontSize = 32.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = _fontSize - 2.0;
      if (_fontSize < 12.0) _fontSize = 12.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate available height - subtract other UI elements to get maximum space for editor
    final screenHeight = MediaQuery.of(context).size.height;
    // Reserve less space for question text, toolbar, and other UI elements
    final reservedSpace = 180.0;
    // Use minimum 400 height or 70% of available space, whichever is larger
    final editorHeight = math.max(400.0, screenHeight * 0.7 - reservedSpace);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text and image
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),

        // Question context
        if (widget.questionContext.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ConvertText(
              text: widget.questionContext,
              textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),

        SizedBox(height: 20),

        // Text formatting toolbar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Text alignment
              IconButton(
                icon: Icon(Icons.format_align_left),
                color: _textAlign == TextAlign.left
                    ? AppTheme.primaryColor
                    : Colors.grey,
                onPressed: () => _changeAlignment(TextAlign.left),
                tooltip: 'Align Left',
              ),
              IconButton(
                icon: Icon(Icons.format_align_center),
                color: _textAlign == TextAlign.center
                    ? AppTheme.primaryColor
                    : Colors.grey,
                onPressed: () => _changeAlignment(TextAlign.center),
                tooltip: 'Align Center',
              ),
              IconButton(
                icon: Icon(Icons.format_align_right),
                color: _textAlign == TextAlign.right
                    ? AppTheme.primaryColor
                    : Colors.grey,
                onPressed: () => _changeAlignment(TextAlign.right),
                tooltip: 'Align Right',
              ),
              VerticalDivider(),

              // Text style
              IconButton(
                icon: Icon(Icons.format_bold),
                color: _isBold ? AppTheme.primaryColor : Colors.grey,
                onPressed: _toggleBold,
                tooltip: 'Bold',
              ),
              IconButton(
                icon: Icon(Icons.format_italic),
                color: _isItalic ? AppTheme.primaryColor : Colors.grey,
                onPressed: _toggleItalic,
                tooltip: 'Italic',
              ),
              VerticalDivider(),

              // Font size
              IconButton(
                icon: Icon(Icons.text_decrease),
                onPressed: _decreaseFontSize,
                tooltip: 'Decrease Font Size',
              ),
              Text(
                '${_fontSize.toInt()}',
                style: TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.text_increase),
                onPressed: _increaseFontSize,
                tooltip: 'Increase Font Size',
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Text editor - updated with dynamic height
        Container(
          height: editorHeight,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _textController,
            maxLines: null,
            expands: true,
            textAlign: _textAlign,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
            ),
            decoration: InputDecoration(
              hintText: "Write your answer here...",
              border: InputBorder.none,
            ),
            onChanged: _onTextChanged,
          ),
        ),

        SizedBox(height: 10),

        // Word count display
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Word count: ${_getWordCount(_textController.text)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
