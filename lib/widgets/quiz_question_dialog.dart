// lib/widgets/quiz_question_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

class QuizQuestionDialog extends StatefulWidget {
  final QuizQuestion question;
  final Function(bool) onAnswer;

  const QuizQuestionDialog({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  State<QuizQuestionDialog> createState() => _QuizQuestionDialogState();
}

class _QuizQuestionDialogState extends State<QuizQuestionDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int? selectedAnswer;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (isAnswered) return;

    HapticFeedback.mediumImpact();

    setState(() {
      selectedAnswer = index;
      isAnswered = true;
    });

    // Show result for 1.5 seconds then close
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.of(context).pop();
      widget.onAnswer(index == widget.question.correctAnswer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Robot image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/robot_question.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...widget.question.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    String optionLabel = String.fromCharCode(
                      65 + index,
                    ); // A, B, C, D

                    Color cardColor = Colors.grey[100]!;
                    Color textColor = Colors.black87;

                    if (isAnswered) {
                      if (index == widget.question.correctAnswer) {
                        cardColor = Colors.green;
                        textColor = Colors.white;
                      } else if (index == selectedAnswer) {
                        cardColor = Colors.red;
                        textColor = Colors.white;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: textColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      optionLabel,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (isAnswered &&
                                    index == widget.question.correctAnswer)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                if (isAnswered &&
                                    index == selectedAnswer &&
                                    index != widget.question.correctAnswer)
                                  const Icon(Icons.cancel, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
