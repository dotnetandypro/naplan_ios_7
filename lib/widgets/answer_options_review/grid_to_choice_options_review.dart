import 'package:flutter/material.dart';
import '../common/dynamic_image.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';

class SelectableGridReview extends StatefulWidget {
  // Review: Class renamed to SelectableGridReview
  final String questionText;
  final String? questionTextImage;
  final int gridSize;
  final List<String> gridItems;
  final List<String>? selectedAnswer; // ✅ Changed from int? to List<String>?
  final Function(List<String>) onItemSelected; // ✅ Changed from Function(int)

  const SelectableGridReview({
    Key? key,
    required this.questionText,
    this.questionTextImage,
    required this.gridSize,
    required this.gridItems,
    this.selectedAnswer, // ✅ Now accepts List<String>
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _SelectableGridReviewState createState() => _SelectableGridReviewState();
}

class _SelectableGridReviewState extends State<SelectableGridReview> {
  int? _selectedAnswer; // ✅ Still stores the selection locally as int

  @override
  void initState() {
    super.initState();
    // ✅ Convert from List<String> to int if needed
    _selectedAnswer = _convertToInt(widget.selectedAnswer);
  }

  @override
  void didUpdateWidget(SelectableGridReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(widget.selectedAnswer, oldWidget.selectedAnswer)) {
      setState(() {
        _selectedAnswer = _convertToInt(widget.selectedAnswer);
      });
    }
  }

  // ✅ Helper method to convert List<String> to int
  int? _convertToInt(List<String>? list) {
    if (list == null || list.isEmpty) return null;
    try {
      return int.parse(list[0]);
    } catch (e) {
      return null;
    }
  }

  // ✅ Helper method to compare lists
  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tileSize = screenWidth / widget.gridSize - 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Display Question Text and Image
        QuestionTextWithImage(
          questionText: widget.questionText,
          questionTextImage: widget.questionTextImage,
        ),
        SizedBox(height: 10),

        // ✅ Selectable Grid (Remembers Selection)
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: widget.gridItems.length,
          itemBuilder: (context, index) {
            bool isSelected = _selectedAnswer == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAnswer = index; // ✅ Save selection locally
                });
                widget.onItemSelected(
                    [index.toString()]); // ✅ Pass index as string in a list
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent // ✅ Highlight only the selected box
                      : Colors.white, // Default
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: widget.gridItems[index].startsWith("http")
                    ? DynamicImage(
                        imageUrl: widget.gridItems[index], maxWidth: tileSize)
                    : Center(
                        child: ConvertText(
                          text: widget.gridItems[index],
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
