import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class FillBlankOptions extends StatefulWidget {
  final String questionText;
  final String questionContext;
  final int size;
  final List<String> selectedAnswers; // ✅ Stores user input
  final Function(List<String>) onAnswerSelected;
  final String? questionTextImage;

  const FillBlankOptions({
    Key? key,
    required this.questionText,
    required this.questionContext,
    required this.size,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    this.questionTextImage,
  }) : super(key: key);

  @override
  _FillBlankOptionsState createState() => _FillBlankOptionsState();
}

class _FillBlankOptionsState extends State<FillBlankOptions> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize controllers with existing answers (if available)
    controllers = List.generate(
      widget.size,
      (index) => TextEditingController(
          text: index < widget.selectedAnswers.length
              ? widget.selectedAnswers[index]
              : ""),
    );
  }

  @override
  void dispose() {
    // ✅ Dispose controllers to prevent memory leaks
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index, String value) {
    List<String> updatedAnswers = List.from(widget.selectedAnswers);

    // ✅ Ensure the list has enough space
    if (updatedAnswers.length < widget.size) {
      updatedAnswers = List.generate(widget.size,
          (i) => updatedAnswers.length > i ? updatedAnswers[i] : "");
    }

    updatedAnswers[index] = value;
    widget.onAnswerSelected(updatedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> textElements = [];
    List<String> parts = widget.questionContext.split("____");

    for (int i = 0; i < parts.length; i++) {
      textElements.add(
        ConvertText(
          text: parts[i],
          textStyle: TextStyle(fontSize: 20),
        ),
      );

      if (i < widget.size) {
        textElements.add(
          SizedBox(
            width: 100, // ✅ More space for input
            height: 40, // ✅ Uniform height
            child: TextField(
              controller: controllers[i],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "____",
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.blue, width: 2), // ✅ Blue border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.blue, width: 2), // ✅ Blue border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              onChanged: (value) => _onTextChanged(i, value),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10, // ✅ Better spacing
          runSpacing: 10,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: textElements,
        ),
      ],
    );
  }
}
