class AttemptListDto {
  final int id;
  final DateTime submittedTime;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final double timeToTake;
  final List<QuestionResultDto> questionResults;

  AttemptListDto({
    required this.id,
    required this.submittedTime,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.timeToTake,
    required this.questionResults,
  });

  factory AttemptListDto.fromJson(Map<String, dynamic> json) {
    return AttemptListDto(
      id: json['Id'] ?? 0,
      submittedTime: json['SubmittedTime'] != null
          ? DateTime.parse(json['SubmittedTime'])
          : DateTime.now(),
      correctAnswers: json['CorrectAnswers'] ?? 0,
      totalQuestions: json['TotalQuestions'] ?? 0,
      score: (json['Score'] ?? 0.0).toDouble(),
      timeToTake: (json['TimeToTake'] ?? 0.0).toDouble(),
      questionResults: json['QuestionResults'] != null
          ? List<QuestionResultDto>.from(
              json['QuestionResults'].map((x) => QuestionResultDto.fromJson(x)))
          : [],
    );
  }
}

class QuestionResultDto {
  final int questionId;
  final String questionText;
  final List<String>? userAnswer;
  final bool isCorrect;
  final bool isFlagged;

  QuestionResultDto({
    required this.questionId,
    required this.questionText,
    this.userAnswer,
    required this.isCorrect,
    required this.isFlagged,
  });

  factory QuestionResultDto.fromJson(Map<String, dynamic> json) {
    return QuestionResultDto(
      questionId: json['QuestionId'] ?? 0,
      questionText: json['QuestionText'] ?? '',
      userAnswer: json['UserAnswer'] != null
          ? List<String>.from(json['UserAnswer'])
          : null,
      isCorrect: json['IsCorrect'] ?? false,
      isFlagged: json['IsFlagged'] ?? false,
    );
  }
}
