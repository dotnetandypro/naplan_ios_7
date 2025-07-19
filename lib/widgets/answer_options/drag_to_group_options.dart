import 'package:flutter/material.dart';
import '../common/question_text_with_image.dart';
import '../common/convert_text.dart';
import '../common/dynamic_image.dart';

class DragToGroupOptions extends StatefulWidget {
  final String questionText;
  final String? questionContext;
  final List<String> options;
  final List<String> categories;
  final Map<String, List<String>> selectedGroups;
  final Function(Map<String, List<String>>) onAnswerSelected;
  final String? questionTextImage;

  const DragToGroupOptions(
      {Key? key,
      required this.questionText,
      this.questionContext,
      required this.options,
      required this.categories,
      required this.selectedGroups,
      required this.onAnswerSelected,
      this.questionTextImage})
      : super(key: key);

  @override
  _DragToGroupOptionsState createState() => _DragToGroupOptionsState();
}

class _DragToGroupOptionsState extends State<DragToGroupOptions> {
  late Map<String, List<String>> selectedGroups;
  late List<String> availableOptions;

  @override
  void initState() {
    super.initState();
    selectedGroups = Map.from(widget.selectedGroups);

    // Ensure all categories exist in the selectedGroups
    for (var category in widget.categories) {
      selectedGroups.putIfAbsent(category, () => []);
    }

    // Compute available options (those not yet assigned to a category)
    availableOptions = List.from(widget.options)
      ..removeWhere((option) =>
          selectedGroups.values.any((list) => list.contains(option)));
  }

  void _onAnswerSelected(String category, String option) {
    setState(() {
      for (var key in selectedGroups.keys) {
        selectedGroups[key]?.remove(option);
      }

      if (!selectedGroups[category]!.contains(option)) {
        selectedGroups[category]!.add(option);
      }

      availableOptions.remove(option);
      widget.onAnswerSelected(Map.from(selectedGroups));
    });
  }

  void _onDragBack(String category, String option) {
    setState(() {
      if (selectedGroups.containsKey(category) &&
          selectedGroups[category]!.contains(option)) {
        selectedGroups[category]!.remove(option);
      }

      if (!availableOptions.contains(option)) {
        availableOptions.add(option);
      }

      widget.onAnswerSelected(Map.from(selectedGroups));
    });
  }

  bool isImageUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith(".png") ||
            url.endsWith(".jpg") ||
            url.endsWith(".jpeg") ||
            url.endsWith(".gif") ||
            url.endsWith(".svg"));
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and check if it's mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Use full width on mobile, 80% on larger screens
    final containerWidth = isMobile ? screenWidth - 32 : screenWidth * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWithImage(
            questionText: widget.questionText,
            questionTextImage: widget.questionTextImage),

        // Display questionContext if available
        if (widget.questionContext != null &&
            widget.questionContext!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: ConvertText(
              text: widget.questionContext!,
              textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),

        SizedBox(height: 10),

        // **Original Drop Area** - Now full width and responsive
        Container(
          width: containerWidth,
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: isMobile ? 200 : 300, // Limit height on mobile
          ),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.withValues(alpha: 0.05),
          ),
          child: DragTarget<String>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) {
              String option = details.data;
              String categoryToRemove = "";

              for (var category in selectedGroups.keys) {
                if (selectedGroups[category]!.contains(option)) {
                  categoryToRemove = category;
                  break;
                }
              }

              if (categoryToRemove.isNotEmpty) {
                _onDragBack(categoryToRemove, option);
              }
            },
            builder: (context, candidateData, rejectedData) {
              if (availableOptions.isEmpty) {
                return Center(
                  child: Text(
                    'All options have been placed',
                    style: TextStyle(
                      fontSize: 16,
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
                      feedback: _buildDragItem(option, isMobile: isMobile),
                      childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildDragItem(option, isMobile: isMobile)),
                      child: _buildDragItem(option, isMobile: isMobile),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20),

        // **Answer Table** - Responsive design
        Container(
          width: containerWidth,
          child: Table(
            border: TableBorder.all(color: Colors.blue),
            columnWidths: {
              0: isMobile ? FixedColumnWidth(100) : IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: widget.categories.map((category) {
              return TableRow(children: [
                Padding(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  child: isImageUrl(category)
                      ? Image.network(category,
                          width: isMobile ? 60 : 80,
                          height: isMobile ? 60 : 80,
                          fit: BoxFit.contain) // ✅ Show image
                      : ConvertText(
                          text: category,
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 20),
                        ),
                ),
                DragTarget<String>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) =>
                      _onAnswerSelected(category, details.data),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      constraints:
                          BoxConstraints(minHeight: isMobile ? 60 : 80),
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        color: selectedGroups[category]!.isEmpty
                            ? Colors.white
                            : Colors.blue[100],
                      ),
                      child: selectedGroups[category]!.isNotEmpty
                          ? Wrap(
                              spacing: isMobile ? 4 : 8,
                              runSpacing: isMobile ? 4 : 8,
                              children: selectedGroups[category]!.map((option) {
                                return GestureDetector(
                                  onLongPress: () =>
                                      _onDragBack(category, option),
                                  child: Draggable<String>(
                                    data: option,
                                    feedback: _buildDragItem(option,
                                        isMobile: isMobile),
                                    child: _buildDragItem(option,
                                        isMobile: isMobile),
                                  ),
                                );
                              }).toList(),
                            )
                          : ConvertText(
                              text: "Drop here",
                              textStyle: TextStyle(
                                  fontSize: isMobile ? 14 : 20,
                                  color: Colors.grey)),
                    );
                  },
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDragItem(String text, {bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      constraints: BoxConstraints(
        minWidth: isMobile ? 80 : 120,
        maxWidth: isMobile ? 150 : 200,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(5),
      ),
      child: isImageUrl(text)
          ? DynamicImage(
              imageUrl: text,
              maxWidth:
                  isMobile ? 60 : 100) // ✅ Displays image with responsive size
          : ConvertText(
              text: text,
              textStyle: TextStyle(fontSize: isMobile ? 16 : 20),
              textAlign: TextAlign.center,
            ),
    );
  }
}
