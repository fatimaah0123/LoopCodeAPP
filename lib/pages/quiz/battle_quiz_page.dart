// lib/pages/quiz/battle_quiz_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../models/quiz_model.dart';
import '../../widgets/battle_question_card.dart';

class BattleQuizPage extends StatefulWidget {
  const BattleQuizPage({Key? key}) : super(key: key);

  @override
  State<BattleQuizPage> createState() => _BattleQuizPageState();
}

class _BattleQuizPageState extends State<BattleQuizPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _starController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _starAnimation;

  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  int _currentQuestion = 0;
  int _playerScore = 0;
  int _opponentScore = 0;
  bool _isAnswered = false;
  bool _isConnected = true; // Simulate connection status

  // Static battle quiz data - will be replaced with dynamic data later
  final List<BattleQuestion> _battleQuestions = [
    BattleQuestion(
      id: 1,
      question: "Apa yang dimaksud dengan loop dalam pemrograman?",
      optionA: "Mengulang kode",
      optionB: "Membuat variabel",
      correctAnswer: "A",
    ),
    BattleQuestion(
      id: 2,
      question: "Manakah yang merupakan tipe data boolean?",
      optionA: "123",
      optionB: "true/false",
      correctAnswer: "B",
    ),
    BattleQuestion(
      id: 3,
      question: "Apa fungsi dari print() dalam pemrograman?",
      optionA: "Menampilkan output",
      optionB: "Menghitung angka",
      correctAnswer: "A",
    ),
    BattleQuestion(
      id: 4,
      question: "Manakah yang termasuk operator perbandingan?",
      optionA: "+",
      optionB: "==",
      correctAnswer: "B",
    ),
    BattleQuestion(
      id: 5,
      question: "Apa yang dimaksud dengan syntax error?",
      optionA: "Kesalahan penulisan kode",
      optionB: "Program berjalan lambat",
      correctAnswer: "A",
    ),
    BattleQuestion(
      id: 6,
      question: "Manakah yang bukan termasuk struktur kontrol?",
      optionA: "if-else",
      optionB: "variable",
      correctAnswer: "B",
    ),
    BattleQuestion(
      id: 7,
      question: "Apa fungsi dari return dalam function?",
      optionA: "Mengembalikan nilai",
      optionB: "Menghentikan program",
      correctAnswer: "A",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
    _simulateConnection();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.elasticOut),
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
          _endBattle();
        }
      });
    });
  }

  void _simulateConnection() {
    // Simulate real-time connection with opponent
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentQuestion < _battleQuestions.length && !_isAnswered) {
        // Simulate opponent answering randomly
        if (DateTime.now().millisecond % 3 == 0) {
          _simulateOpponentAnswer();
        }
      }
    });
  }

  void _simulateOpponentAnswer() {
    // Simulate opponent's answer
    bool isCorrect = DateTime.now().millisecond % 2 == 0;
    setState(() {
      if (isCorrect) {
        _opponentScore++;
      }
      _nextQuestion();
    });
  }

  void _onAnswerSelected(String answer) {
    if (_isAnswered) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isAnswered = true;
      bool isCorrect =
          answer == _battleQuestions[_currentQuestion].correctAnswer;

      if (isCorrect) {
        _playerScore++;
        _starController.forward().then((_) {
          _starController.reset();
        });
      }
    });

    // Auto advance to next question after 2 seconds
    Timer(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _battleQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _isAnswered = false;
      });
    } else {
      _endBattle();
    }
  }

  void _endBattle() {
    _timer?.cancel();
    _showBattleResult();
  }

  void _showBattleResult() {
    String result;
    String robotImage;
    Color resultColor;

    if (_playerScore > _opponentScore) {
      result = "VICTORY!";
      robotImage = 'assets/images/robot_victory.png';
      resultColor = Colors.green;
    } else if (_playerScore < _opponentScore) {
      result = "DEFEAT!";
      robotImage = 'assets/images/robot_sad.png';
      resultColor = Colors.red;
    } else {
      result = "DRAW!";
      robotImage = 'assets/images/robot_neutral.png';
      resultColor = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Robot image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(robotImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('You', style: TextStyle(fontSize: 16)),
                          Row(
                            children: List.generate(
                              _playerScore,
                              (index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            '$_playerScore',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Opponent',
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: List.generate(
                              _opponentScore,
                              (index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            '$_opponentScore',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Reset for new battle
                      _resetBattle();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetBattle() {
    setState(() {
      _timeLeft = 300;
      _currentQuestion = 0;
      _playerScore = 0;
      _opponentScore = 0;
      _isAnswered = false;
    });
    _startTimer();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Battle Mode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Icon(Icons.volume_up, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer and Question Counter
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(_timeLeft),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question ${_currentQuestion + 1}/7',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Score Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Player Score
                Column(
                  children: [
                    const Text(
                      'You',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _starAnimation,
                      builder: (context, child) {
                        return Row(
                          children: List.generate(
                            _playerScore,
                            (index) => Transform.scale(
                              scale: _starAnimation.value,
                              child: const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // VS
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/robot_battle.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Opponent Score
                Column(
                  children: [
                    const Text(
                      'Opponent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        _opponentScore,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Question Card
          if (_currentQuestion < _battleQuestions.length)
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                    child: Opacity(
                      opacity: _slideAnimation.value,
                      child: BattleQuestionCard(
                        question: _battleQuestions[_currentQuestion],
                        onAnswerSelected: _onAnswerSelected,
                        isAnswered: _isAnswered,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
