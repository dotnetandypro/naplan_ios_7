enum QuestionType {
  multipleChoice,
  sentenceSelection,
  selectionMultiple,
  multipleTrueFalse,
  wordMatching,
  dragAndDropImages,
  dropdownSelection,
  multipleChoiceImage,
  dragToOrder,
  dragToChoice,
  dragToGroup,
  gridToChoice,
  fillTheBlank,
  narrativeWriting,
  persuasiveWriting
}

extension QuestionTypeExtension on QuestionType {
  static QuestionType fromString(String type) {
    switch (type) {
      case "multipleChoice":
      case "MultipleChoice":
        return QuestionType.multipleChoice;
      case "sentenceSelection":
      case "SentenceSelection":
        return QuestionType.sentenceSelection;
      case "selectionMultiple":
      case "SelectionMultiple":
        return QuestionType.selectionMultiple;
      case "multipleTrueFalse":
      case "MultipleTrueFalse":
        return QuestionType.multipleTrueFalse;
      case "wordMatching":
      case "WordMatching":
        return QuestionType.wordMatching;
      case "dragAndDropImages":
      case "DragAndDropImages":
        return QuestionType.dragAndDropImages;
      case "dropdownSelection":
      case "DropdownSelection":
        return QuestionType.dropdownSelection;
      case "multipleChoiceImage":
      case "MultipleChoiceImage":
        return QuestionType.multipleChoiceImage;
      case "dragToOrder":
      case "DragToOrder":
        return QuestionType.dragToOrder;
      case "dragToChoice":
      case "DragToChoice":
        return QuestionType.dragToChoice;
      case "dragToGroup":
      case "DragToGroup":
        return QuestionType.dragToGroup;
      case "gridToChoice":
      case "GridToChoice":
        return QuestionType.gridToChoice;
      case "fillTheBlank":
      case "FillTheBlank":
        return QuestionType.fillTheBlank;
      case "narrativeWriting":
      case "NarrativeWriting":
        return QuestionType.narrativeWriting;
      case "persuasiveWriting":
      case "PersuasiveWriting":
        return QuestionType.persuasiveWriting;
      default:
        throw Exception("Unknown QuestionType: $type");
    }
  }
}
