// lib/pages/quiz/solo_quiz_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../models/quiz_model.dart';
import '../../widgets/quiz_card.dart';
import '../../widgets/quiz_question_dialog.dart';
import '../../theme/app_colors.dart';

class SoloQuizPage extends StatefulWidget {
  const SoloQuizPage({Key? key}) : super(key: key);

  @override
  State<SoloQuizPage> createState() => _SoloQuizPageState();
}

class _SoloQuizPageState extends State<SoloQuizPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  int _timeLeft = 600; // 10 minutes in seconds
  int _currentScore = 0;
  int _answeredQuestions = 0;
  List<bool> _cardAnswered = List.generate(10, (index) => false);

  // Static quiz data - will be replaced with dynamic data later
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 1,
      question: "Apa yang dimaksud dengan variabel dalam pemrograman?",
      options: [
        "Tempat menyimpan data",
        "Fungsi untuk menghitung",
        "Perintah untuk menampilkan",
        "Cara membuat loop",
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      id: 2,
      question: "Manakah yang merupakan tipe data untuk menyimpan angka bulat?",
      options: ["String", "Integer", "Boolean", "Float"],
      correctAnswer: 1,
    ),
    QuizQuestion(
      id: 3,
      question: "Apa fungsi dari statement 'if' dalam pemrograman?",
      options: [
        "Mengulang kode",
        "Membuat variabel",
        "Membuat keputusan",
        "Menghentikan program",
      ],
      correctAnswer: 2,
    ),
    QuizQuestion(
      id: 4,
      question: "Manakah yang termasuk loop dalam pemrograman?",
      options: ["if-else", "switch", "for", "return"],
      correctAnswer: 2,
    ),
    QuizQuestion(
      id: 5,
      question: "Apa yang dimaksud dengan debugging?",
      options: [
        "Menulis kode baru",
        "Menjalankan program",
        "Mencari dan memperbaiki error",
        "Membuat dokumentasi",
      ],
      correctAnswer: 2,
    ),
    QuizQuestion(
      id: 6,
      question: "Manakah yang bukan termasuk operator matematika?",
      options: ["+", "-", "*", "&&"],
      correctAnswer: 3,
    ),
    QuizQuestion(
      id: 7,
      question: "Apa fungsi dari komentar dalam kode?",
      options: [
        "Menjalankan program",
        "Menjelaskan kode",
        "Membuat variabel",
        "Menghentikan eksekusi",
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      id: 8,
      question:
          "Manakah yang merupakan struktur data untuk menyimpan banyak nilai?",
      options: ["Variable", "Array", "Function", "Class"],
      correctAnswer: 1,
    ),
    QuizQuestion(
      id: 9,
      question: "Apa yang dimaksud dengan algoritma?",
      options: [
        "Bahasa pemrograman",
        "Langkah-langkah untuk menyelesaikan masalah",
        "Tipe data",
        "Perintah komputer",
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      id: 10,
      question: "Manakah yang termasuk bahasa pemrograman?",
      options: ["HTML", "CSS", "Python", "SQL"],
      correctAnswer: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endQuiz();
        }
      });
    });
  }

  void _endQuiz() {
    _timer?.cancel();
    _showResultDialog();
  }

  void _showResultDialog() {
    int stars = _calculateStars();
    String message = _getResultMessage(stars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Robot image
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/robot.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.successColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < stars ? Colors.yellow : AppColors.textLight,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Skor: $_currentScore/100',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Kembali ke Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStars() {
    if (_currentScore >= 100) return 5;
    if (_currentScore >= 80) return 4;
    if (_currentScore >= 60) return 3;
    if (_currentScore >= 40) return 2;
    if (_currentScore >= 20) return 1;
    return 0;
  }

  String _getResultMessage(int stars) {
    if (stars == 5) return "EXCELLENT!";
    if (stars >= 4) return "GREAT JOB!";
    if (stars >= 3) return "GOOD!";
    if (stars >= 2) return "KEEP TRYING!";
    return "PRACTICE MORE!";
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onCardTap(int index) {
    if (_cardAnswered[index]) return;

    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizQuestionDialog(
        question: _questions[index],
        onAnswer: (isCorrect) {
          setState(() {
            _cardAnswered[index] = true;
            _answeredQuestions++;
            if (isCorrect) {
              _currentScore += 10;
            }
          });

          if (_answeredQuestions >= 10) {
            _endQuiz();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solo Mode Quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.cardBgColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Timer and Score Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, AppColors.cardBgColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.errorColor),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, AppColors.cardBgColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          '$_currentScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Robot Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Image(
                      image: AssetImage('assets/images/robot.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Progress Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: $_answeredQuestions/10',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _answeredQuestions / 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryPurple,
                              AppColors.secondaryPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quiz Cards Grid
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                    child: Opacity(
                      opacity: _slideAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return QuizCard(
                              number: index + 1,
                              isAnswered: _cardAnswered[index],
                              onTap: () => _onCardTap(index),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
