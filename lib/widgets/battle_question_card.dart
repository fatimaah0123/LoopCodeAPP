// lib/widgets/battle_question_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

class BattleQuestionCard extends StatefulWidget {
  final BattleQuestion question;
  final Function(String) onAnswerSelected;
  final bool isAnswered;

  const BattleQuestionCard({
    Key? key,
    required this.question,
    required this.onAnswerSelected,
    required this.isAnswered,
  }) : super(key: key);

  @override
  State<BattleQuestionCard> createState() => _BattleQuestionCardState();
}

class _BattleQuestionCardState extends State<BattleQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (widget.isAnswered) return;

    HapticFeedback.heavyImpact();

    setState(() {
      selectedAnswer = answer;
    });

    widget.onAnswerSelected(answer);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Question
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Battle Options
                  Row(
                    children: [
                      // Option A
                      Expanded(
                        child: _buildBattleOption(
                          'A',
                          widget.question.optionA,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Option B
                      Expanded(
                        child: _buildBattleOption(
                          'B',
                          widget.question.optionB,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBattleOption(String letter, String text, Color color) {
    bool isSelected = selectedAnswer == letter;
    bool isCorrect = widget.question.correctAnswer == letter;

    Color cardColor = color;
    if (widget.isAnswered) {
      if (isCorrect) {
        cardColor = Colors.green;
      } else if (isSelected) {
        cardColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
