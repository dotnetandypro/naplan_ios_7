import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';
import '../common/dynamic_image.dart';

class DragToOrderOptionsReview extends StatefulWidget {
  final String questionText;
  final List<String> categories;
  final List<String> options;
  final List<String?> selectedOrder;
  final Function(List<String?>) onAnswerSelected;
  final String? questionTextImage;

  const DragToOrderOptionsReview(
      {Key? key,
      required this.questionText,
      required this.categories,
      required this.options,
      required this.selectedOrder,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  _DragToOrderOptionsReviewState createState() =>
      _DragToOrderOptionsReviewState();
}

class _DragToOrderOptionsReviewState extends State<DragToOrderOptionsReview> {
  late List<String?> selectedOrder;
  late List<String> availableOptions;

  @override
  void initState() {
    super.initState();
    selectedOrder = List<String?>.from(widget.selectedOrder);

    while (selectedOrder.length < widget.categories.length) {
      selectedOrder.add(null);
    }

    availableOptions = List<String>.from(widget.options)
        .where((option) => !selectedOrder.contains(option))
        .toList();
  }

  void _onAnswerSelected(int rowIndex, String option) {
    setState(() {
      // If this option is already placed somewhere, remove it from there
      int previousIndex = selectedOrder.indexOf(option);
      if (previousIndex != -1) selectedOrder[previousIndex] = null;

      // Remove option from available options
      availableOptions.remove(option);

      // If there was already an option in this position, move it back to available
      String? existing = selectedOrder[rowIndex];
      if (existing != null) availableOptions.add(existing);

      // Place the new option
      selectedOrder[rowIndex] = option;
      widget.onAnswerSelected(selectedOrder);
    });
  }

  void _onDragBack(int rowIndex) {
    setState(() {
      String? removedOption = selectedOrder[rowIndex];

      if (removedOption != null) {
        selectedOrder[rowIndex] = null;

        // Add back to available options if not already there
        if (!availableOptions.contains(removedOption)) {
          availableOptions.add(removedOption);
        }
      }

      widget.onAnswerSelected(selectedOrder);
    });
  }

  bool _isImageUrl(String text) {
    return text.startsWith("http") &&
        (text.endsWith(".png") ||
            text.endsWith(".jpg") ||
            text.endsWith(".jpeg") ||
            text.endsWith(".gif"));
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and check if it's mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Use full width on mobile, 90% on larger screens
    final containerWidth = isMobile ? screenWidth - 32 : screenWidth * 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
            questionText: widget.questionText,
            questionTextImage: widget.questionTextImage),
        SizedBox(height: 10),

        // **Drag Source (Unselected Items)** - Responsive design
        Container(
          width: containerWidth,
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.withValues(alpha: 0.05),
          ),
          constraints: BoxConstraints(
            minHeight: isMobile ? 60 : 80,
            maxHeight: isMobile ? 150 : 200,
          ),
          child: DragTarget<String>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) =>
                _onDragBack(selectedOrder.indexOf(details.data)),
            builder: (context, candidateData, rejectedData) {
              if (availableOptions.isEmpty) {
                return Center(
                  child: Text(
                    'All options have been placed',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Wrap(
                  spacing: isMobile ? 6 : 8,
                  runSpacing: isMobile ? 6 : 8,
                  alignment: WrapAlignment.start,
                  children: availableOptions.map((option) {
                    return Draggable<String>(
                      data: option,
                      feedback:
                          _buildDraggableOption(option, isMobile: isMobile),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child:
                            _buildDraggableOption(option, isMobile: isMobile),
                      ),
                      child: _buildDraggableOption(option, isMobile: isMobile),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20),

        // **Answer Table with Image Support** - Responsive design
        Container(
          width: containerWidth,
          child: Table(
            border: TableBorder.all(color: Colors.blue),
            columnWidths: {
              0: isMobile ? FixedColumnWidth(80) : IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: List.generate(widget.categories.length, (index) {
              return TableRow(children: [
                // **Left Column: Display Category as Image or Text**
                Container(
                  height: isMobile ? 50 : 60,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue),
                  ),
                  child: _isImageUrl(widget.categories[index])
                      ? Image.network(widget.categories[index],
                          height: isMobile ? 35 : 50,
                          fit: BoxFit.contain) // ✅ Display Image
                      : ConvertText(
                          text: widget.categories[index], // ✅ Display Text
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                              fontSize: isMobile ? 14 : 20,
                              fontWeight: FontWeight.bold),
                        ),
                ),

                // **Right Column: Drop Target**
                DragTarget<String>(
                  onWillAcceptWithDetails: (details) =>
                      selectedOrder[index] == null,
                  onAcceptWithDetails: (details) =>
                      _onAnswerSelected(index, details.data),
                  builder: (context, candidateData, rejectedData) {
                    String? selectedOption = selectedOrder[index];

                    return GestureDetector(
                      onLongPress: selectedOption != null
                          ? () => _onDragBack(index)
                          : null,
                      child: Container(
                        height: isMobile ? 50 : 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          color: selectedOption == null
                              ? Colors.white
                              : Colors.blue[100],
                        ),
                        child: selectedOption == null
                            ? ConvertText(
                                text: "Drop here",
                                textStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isMobile ? 12 : 16,
                                ))
                            : Draggable<String>(
                                data: selectedOption,
                                feedback: _buildDraggableOption(selectedOption,
                                    isMobile: isMobile),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: _buildDraggableOption(selectedOption,
                                      isMobile: isMobile),
                                ),
                                child: _buildDraggableOption(selectedOption,
                                    isMobile: isMobile),
                              ),
                      ),
                    );
                  },
                ),
              ]);
            }),
          ),
        ),
      ],
    );
  }

  bool isImageUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith(".png") ||
            url.endsWith(".jpg") ||
            url.endsWith(".jpeg") ||
            url.endsWith(".gif") ||
            url.endsWith(".svg"));
  }

  Widget _buildDraggableOption(String text, {bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      margin: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
      constraints: BoxConstraints(
        minWidth: isMobile ? 60 : 80,
        maxWidth: isMobile ? 120 : 160,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(5),
      ),
      child: isImageUrl(text)
          ? DynamicImage(
              imageUrl: text,
              maxWidth: isMobile
                  ? 60
                  : 100) // ✅ Displays image if URL with responsive size
          : ConvertText(
              text: text,
              textStyle: TextStyle(fontSize: isMobile ? 14 : 20),
              textAlign: TextAlign.center,
            ), // ✅ Displays text otherwise with responsive size
    );
  }
}
