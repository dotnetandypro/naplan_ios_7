import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';
import '../common/convert_text_span.dart';

class DropdownSelectionQuestion extends StatefulWidget {
  final String questionText;
  final String questionContext;
  final List<String> options;
  final List<String>
      selectedAnswers; // Changed from Map<String, String> to List<String>
  final Function(List<String>) onSelected; // Changed function signature
  final String? questionTextImage;

  const DropdownSelectionQuestion(
      {Key? key,
      required this.questionText,
      required this.questionContext,
      required this.options,
      required this.selectedAnswers,
      required this.onSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  _DropdownSelectionQuestionState createState() =>
      _DropdownSelectionQuestionState();
}

class _DropdownSelectionQuestionState extends State<DropdownSelectionQuestion> {
  late List<String>
      selectedAnswers; // Changed from Map<String, String> to List<String>
  late Map<String, String>
      _internalSelections; // Internal map for tracking selections

  @override
  void initState() {
    super.initState();
    // Initialize with existing answers
    selectedAnswers = List.from(widget.selectedAnswers);

    // Create internal map for easier handling of selections
    _internalSelections = {};

    // Extract placeholders from context
    RegExp regex = RegExp(r"\[(\d+)\]");
    Iterable<Match> matches = regex.allMatches(widget.questionContext);
    List<String> placeholders = matches.map((m) => m.group(1)!).toList();

    // Convert existing list answers to internal map
    for (String answer in selectedAnswers) {
      if (answer.isNotEmpty && answer.contains(':')) {
        String placeholder = answer.split(':')[0];
        String value = answer.substring(answer.indexOf(':') + 1);
        _internalSelections[placeholder] = value;
      }
    }

    // Debug
    print("Initializing with selected answers: $selectedAnswers");
    print("Internal selections map: $_internalSelections");
  }

  @override
  void didUpdateWidget(DropdownSelectionQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal map when widget is updated with new selected answers
    if (oldWidget.selectedAnswers != widget.selectedAnswers) {
      selectedAnswers = List.from(widget.selectedAnswers);

      // Extract placeholders from context
      RegExp regex = RegExp(r"\[(\d+)\]");
      Iterable<Match> matches = regex.allMatches(widget.questionContext);
      List<String> placeholders = matches.map((m) => m.group(1)!).toList();

      // Process any new answers
      for (int i = 0; i < selectedAnswers.length; i++) {
        if (i < placeholders.length && selectedAnswers[i].isNotEmpty) {
          String answer = selectedAnswers[i];
          if (answer.contains(':')) {
            String placeholder = answer.split(':')[0];
            String value = answer.substring(answer.indexOf(':') + 1);
            _internalSelections[placeholder] = value;
          }
        }
      }
    }
  }

  // Convert internal map to list for the parent widget
  void _updateSelectedAnswers() {
    // Extract placeholders in order
    RegExp regex = RegExp(r"\[(\d+)\]");
    Iterable<Match> matches = regex.allMatches(widget.questionContext);
    List<String> placeholders = matches.map((m) => m.group(1)!).toList();

    // Create a list with the same size as placeholders
    selectedAnswers = List.filled(placeholders.length, "");

    // Fill in the values from the internal map
    for (int i = 0; i < placeholders.length; i++) {
      String placeholder = placeholders[i];
      if (_internalSelections.containsKey(placeholder)) {
        // Format as "number:value" to preserve the placeholder number
        selectedAnswers[i] =
            "${placeholder}:${_internalSelections[placeholder]!}";
      }
    }

    widget.onSelected(selectedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Extract placeholders (e.g., [1], [2]) from questionContext
    RegExp regex = RegExp(r"\[(\d+)\]");
    Iterable<Match> matches = regex.allMatches(widget.questionContext);
    List<String> placeholders = matches.map((m) => m.group(1)!).toList();

    // ✅ Split sentence based on placeholders
    List<String> sentenceParts = widget.questionContext.split(regex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
            questionText: widget.questionText,
            questionTextImage: widget.questionTextImage),
        SizedBox(height: 12),
        RichText(
          text: ConvertTextSpan(
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            children: [
              for (int index = 0; index < sentenceParts.length; index++) ...[
                ConvertTextSpan(
                    text: sentenceParts[index]), // ✅ Text before dropdown
                if (index <
                    placeholders.length) // ✅ Ensure there's a placeholder
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      height: 35, // ✅ Reduced height
                      padding: EdgeInsets.symmetric(
                          horizontal: 8), // ✅ Adds padding inside
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blue, width: 2), // ✅ Blue border
                        borderRadius:
                            BorderRadius.circular(8), // ✅ Rounded corners
                        color: Colors.white, // ✅ Background to match text
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Builder(builder: (context) {
                          // Get the filtered items for this dropdown
                          final filteredItems = widget.options
                              .where((opt) =>
                                  opt.startsWith("${placeholders[index]}:"))
                              .toList();

                          // Extract just the values for validation
                          final validValues = filteredItems
                              .map((opt) => opt.substring(opt.indexOf(':') + 1))
                              .toList();

                          // Check if the current value is valid
                          final currentValue =
                              _internalSelections[placeholders[index]];
                          final isValueValid = currentValue != null &&
                              validValues.contains(currentValue);

                          return DropdownButton<String>(
                            // Only set value if it exists in the items
                            value: isValueValid ? currentValue : null,
                            hint: ConvertText(text: "Select"),
                            disabledHint: ConvertText(text: "Select"),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            dropdownColor: Colors.white,
                            iconSize: 18,
                            isDense: true,
                            // Map the filtered items
                            items: filteredItems.map((opt) {
                              String fullText =
                                  opt.substring(opt.indexOf(':') + 1);
                              return DropdownMenuItem<String>(
                                value: fullText,
                                child: ConvertText(text: fullText),
                              );
                            }).toList(),
                            onChanged: filteredItems.isEmpty
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      if (newValue != null) {
                                        _internalSelections[
                                            placeholders[index]] = newValue;
                                        _updateSelectedAnswers();
                                      }
                                    });
                                  },
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
