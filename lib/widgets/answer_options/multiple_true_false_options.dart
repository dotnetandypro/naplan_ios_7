import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/dynamic_image.dart'; // ✅ Import DynamicImage
import '../common/convert_text.dart';

class MultipleTrueFalseOptions extends StatefulWidget {
  final String questionText;
  final List<String> options; // ✅ Statements (Text or Image URLs)
  final List<String>
      selectedAnswers; // Format: [category:option, category:option]
  final List<String> categories; // ✅ Categories (Text or Image URLs)
  final Function(List<String>)
      onAnswerSelected; // Sends answers in format "category:option"
  final String? questionTextImage;

  const MultipleTrueFalseOptions({
    Key? key,
    required this.questionText,
    required this.options,
    required this.selectedAnswers,
    required this.categories,
    required this.onAnswerSelected,
    this.questionTextImage,
  }) : super(key: key);

  @override
  _MultipleTrueFalseOptionsState createState() =>
      _MultipleTrueFalseOptionsState();
}

class _MultipleTrueFalseOptionsState extends State<MultipleTrueFalseOptions> {
  late List<String> userAnswers;

  @override
  void initState() {
    super.initState();
    userAnswers = List.from(widget.selectedAnswers);

    // If we need to initialize empty answers, create them in the proper format
    if (userAnswers.isEmpty) {
      userAnswers = List.generate(widget.options.length, (index) => "");
    }
  }

  @override
  void didUpdateWidget(MultipleTrueFalseOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAnswers != widget.selectedAnswers) {
      setState(() {
        userAnswers = List.from(widget.selectedAnswers);
      });
    }
  }

  void _selectAnswer(int optionIndex, int categoryIndex) {
    setState(() {
      // Format the answer as "category:option"
      final category = widget.categories[categoryIndex];
      final option = widget.options[optionIndex];
      userAnswers[optionIndex] = "$category:$option";

      widget.onAnswerSelected(List.from(userAnswers)); // ✅ Notify parent
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // ✅ Get screen width

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),
        SizedBox(height: 10),

        // ✅ Responsive Table with Options & Categories
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: {
            0: FlexColumnWidth(2), // ✅ Statement column
            for (int i = 1; i <= widget.categories.length; i++)
              i: FlexColumnWidth(1), // ✅ Dynamic category columns
          },
          children: [
            // ✅ Header Row (Dynamic Categories)
            TableRow(
              children: [
                _buildTableHeaderCell(""), // Empty for statements column
                ...widget.categories.map(
                    (category) => _buildCategoryCell(category, screenWidth)),
              ],
            ),

            // ✅ Rows for each option
            ...List.generate(widget.options.length, (index) {
              return TableRow(
                children: [
                  _buildOptionCell(widget.options[index], screenWidth),
                  ...List.generate(
                    widget.categories.length,
                    (catIndex) => _buildCheckBox(index, catIndex),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  // ✅ Builds a text or image category header cell (Responsive)
  Widget _buildCategoryCell(String category, double screenWidth) {
    bool isImage = Uri.tryParse(category)?.hasAbsolutePath ?? false;
    return Padding(
      padding: EdgeInsets.all(8),
      child: isImage
          ? DynamicImage(imageUrl: category, maxWidth: screenWidth * 0.15)
          : ConvertText(
              text: category,
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
    );
  }

  // ✅ Builds a text or image option cell (Responsive)
  Widget _buildOptionCell(String option, double screenWidth) {
    bool isImage = Uri.tryParse(option)?.hasAbsolutePath ?? false;
    return Padding(
      padding: EdgeInsets.all(8),
      child: isImage
          ? DynamicImage(imageUrl: option, maxWidth: screenWidth * 0.15)
          : ConvertText(
              text: option,
              textStyle: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
    );
  }

  // ✅ Builds a selectable check box
  Widget _buildCheckBox(int optionIndex, int categoryIndex) {
    final category = widget.categories[categoryIndex];
    final option = widget.options[optionIndex];
    final expectedAnswer = "$category:$option";

    return Center(
      child: Checkbox(
        value: userAnswers[optionIndex] == expectedAnswer,
        onChanged: (isChecked) {
          if (isChecked == true) {
            _selectAnswer(optionIndex, categoryIndex);
          }
        },
      ),
    );
  }

  // ✅ Builds the header cell for category titles
  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ConvertText(
        text: text,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
