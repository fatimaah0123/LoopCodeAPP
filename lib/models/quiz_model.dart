// lib/models/quiz_model.dart
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  // Factory constructor for creating from JSON (for future database integration)
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }

  // Method to convert to JSON (for future database integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class BattleQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String correctAnswer; // "A" or "B"
  final String? explanation;

  BattleQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.correctAnswer,
    this.explanation,
  });

  // Factory constructor for creating from JSON (for future database integration)
  factory BattleQuestion.fromJson(Map<String, dynamic> json) {
    return BattleQuestion(
      id: json['id'],
      question: json['question'],
      optionA: json['optionA'],
      optionB: json['optionB'],
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }

  // Method to convert to JSON (for future database integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTaken; // in seconds
  final DateTime completedAt;
  final String mode; // "solo" or "battle"

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.completedAt,
    required this.mode,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;

  // Factory constructor for creating from JSON (for future database integration)
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      timeTaken: json['timeTaken'],
      completedAt: DateTime.parse(json['completedAt']),
      mode: json['mode'],
    );
  }

  // Method to convert to JSON (for future database integration)
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeTaken': timeTaken,
      'completedAt': completedAt.toIso8601String(),
      'mode': mode,
    };
  }
}

class BattleResult {
  final int playerScore;
  final int opponentScore;
  final String result; // "win", "lose", "draw"
  final int totalQuestions;
  final int timeTaken; // in seconds
  final DateTime completedAt;
  final String? opponentName;

  BattleResult({
    required this.playerScore,
    required this.opponentScore,
    required this.result,
    required this.totalQuestions,
    required this.timeTaken,
    required this.completedAt,
    this.opponentName,
  });

  // Factory constructor for creating from JSON (for future database integration)
  factory BattleResult.fromJson(Map<String, dynamic> json) {
    return BattleResult(
      playerScore: json['playerScore'],
      opponentScore: json['opponentScore'],
      result: json['result'],
      totalQuestions: json['totalQuestions'],
      timeTaken: json['timeTaken'],
      completedAt: DateTime.parse(json['completedAt']),
      opponentName: json['opponentName'],
    );
  }

  // Method to convert to JSON (for future database integration)
  Map<String, dynamic> toJson() {
    return {
      'playerScore': playerScore,
      'opponentScore': opponentScore,
      'result': result,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'completedAt': completedAt.toIso8601String(),
      'opponentName': opponentName,
    };
  }
}
