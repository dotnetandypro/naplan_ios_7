import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class DragToChoiceOptionsReview extends StatefulWidget {
  final String questionText;
  final String questionContext;
  final List<String> options;
  final List<String?> selectedAnswers;
  final Function(List<String?>) onAnswerSelected;
  final String? questionTextImage;
  final int size;

  const DragToChoiceOptionsReview({
    Key? key,
    required this.questionText,
    required this.questionContext,
    required this.options,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    this.questionTextImage,
    required this.size,
  }) : super(key: key);

  @override
  _DragToChoiceOptionsReviewState createState() =>
      _DragToChoiceOptionsReviewState();
}

class _DragToChoiceOptionsReviewState extends State<DragToChoiceOptionsReview> {
  late List<String?> droppedAnswers;

  @override
  void initState() {
    super.initState();
    droppedAnswers = List.from(widget.selectedAnswers); // ✅ Persist state
    if (droppedAnswers.length < widget.size) {
      droppedAnswers
          .addAll(List.filled(widget.size - droppedAnswers.length, null));
    }
  }

  @override
  void didUpdateWidget(covariant DragToChoiceOptionsReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Prevent overwriting existing answers when the widget rebuilds
    if (widget.selectedAnswers != oldWidget.selectedAnswers) {
      setState(() {
        droppedAnswers = List.from(widget.selectedAnswers);
        if (droppedAnswers.length < widget.size) {
          droppedAnswers
              .addAll(List.filled(widget.size - droppedAnswers.length, null));
        }
      });
    }
  }

  void _onAnswerDropped(int index, String option) {
    setState(() {
      droppedAnswers[index] = option;
    });

    // ✅ Convert List<String?> to List<String> by filtering out null values
    widget.onAnswerSelected(droppedAnswers.map((e) => e ?? "").toList());
  }

  void _removeAnswer(int index) {
    setState(() {
      droppedAnswers[index] = null;
    });

    // ✅ Convert List<String?> to List<String> before calling onAnswerSelected
    widget.onAnswerSelected(droppedAnswers.map((e) => e ?? "").toList());
  }

  @override
  Widget build(BuildContext context) {
    List<String> remainingOptions = widget.options
        .where((option) => !droppedAnswers.contains(option))
        .toList();

    List<String> parts = widget.questionContext.split("____");
    List<Widget> sentenceWidgets = [];

    for (int i = 0; i < parts.length; i++) {
      sentenceWidgets.add(ConvertText(
        text: parts[i],
        textStyle: TextStyle(fontSize: 20), // Increased from 16
      ));

      if (i < widget.size) {
        sentenceWidgets.add(SizedBox(width: 5));
        sentenceWidgets.add(_buildDropTarget(i));
        sentenceWidgets.add(SizedBox(width: 5));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
            questionText: widget.questionText,
            questionTextImage: widget.questionTextImage),
        SizedBox(height: 16), // Increased from 12
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8, // Increased from 5
          runSpacing: 12, // Increased from 10
          children: sentenceWidgets,
        ),
        SizedBox(height: 24), // Increased from 20
        Wrap(
          spacing: 12, // Increased from 10
          runSpacing: 12, // Increased from 10
          children: remainingOptions.map((option) {
            return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: _buildChoiceChip(option),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _buildChoiceChip(option),
              ),
              child: _buildChoiceChip(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropTarget(int index) {
    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (String option) => _onAnswerDropped(index, option),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onDoubleTap:
              droppedAnswers[index] != null ? () => _removeAnswer(index) : null,
          child: Container(
            width: 120, // Increased from 100
            height: 50, // Increased from 40
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 3),
              color: droppedAnswers[index] != null
                  ? Colors.blue[200]
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: droppedAnswers[index] != null
                ? ConvertText(
                    text: droppedAnswers[index]!,
                    textStyle: TextStyle(
                        fontSize: 20, // Increased from 16
                        fontWeight: FontWeight.bold,
                        color: Colors.black))
                : ConvertText(
                    text: "Drag here",
                    textStyle: TextStyle(
                        fontSize: 20, color: Colors.grey)), // Updated font size
          ),
        );
      },
    );
  }

  Widget _buildChoiceChip(String option) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // Increased padding
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10), // Slightly more rounded
        border: Border.all(color: Colors.blue.shade700, width: 2),
      ),
      child: ConvertText(
          text: option,
          textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold)), // Increased from 16
    );
  }
}
