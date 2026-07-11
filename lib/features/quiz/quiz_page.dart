import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/quiz.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/challenge_provider.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _correctCount = 0;
  bool _isAnswered = false;
  bool _isFinished = false;
  late Timer _timer;
  int _secondsRemaining;
  late List<int> _shuffledOrder;

  _QuizPageState() : _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.quiz.timeMinutes * 60;
    _shuffledOrder = List.generate(widget.quiz.questions.length, (i) => i);
    _shuffledOrder.shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        _finishQuiz();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  QuizQuestion get _currentQuizQuestion =>
      widget.quiz.questions[_shuffledOrder[_currentQuestion]];

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;
      if (index == _currentQuizQuestion.correctIndex) {
        _correctCount++;
        HapticFeedback.successNotification();
      } else {
        HapticFeedback.warningNotification();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer.cancel();
    context.read<SanctuaryProvider>().addStudyXp(_correctCount * 5);
    final achievements = context.read<AchievementProvider>();
    achievements.tryUnlock(AchievementId.firstQuiz);
    if (_correctCount >= widget.quiz.questions.length * 0.8) {
      achievements.tryUnlock(AchievementId.quizMaster);
    }
    context.read<ChallengeProvider>().addProgress(ChallengeType.quizQuestions, widget.quiz.questions.length);
    setState(() => _isFinished = true);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final min = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final sec = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResults();

    final question = _currentQuizQuestion;
    final progress = (_currentQuestion + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsRemaining < 60 ? AppColors.error.withValues(alpha: 0.2) : AppColors.darkCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formattedTime,
              style: TextStyle(
                color: _secondsRemaining < 60 ? AppColors.error : AppColors.lightText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(progress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pregunta ${_currentQuestion + 1}/${widget.quiz.questions.length}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...question.options.asMap().entries.map((entry) =>
                      _buildOption(entry.key, entry.value, question.correctIndex)),
                  if (_isAnswered && question.explanation != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedAnswer == question.correctIndex
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAnswer == question.correctIndex
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedAnswer == question.correctIndex
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: _selectedAnswer == question.correctIndex
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.explanation!,
                              style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return ClipRRect(
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.darkCard,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 4,
      ),
    );
  }

  Widget _buildOption(int index, String text, int correctIndex) {
    final isSelected = _selectedAnswer == index;
    Color bgColor = AppColors.darkCard;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.lightText;

    if (_isAnswered) {
      if (index == correctIndex) {
        bgColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (isSelected) {
        bgColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error;
        textColor = AppColors.error;
      }
    } else if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? borderColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? borderColor : AppColors.secondaryText,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _isAnswered && index == correctIndex
                      ? '✓'
                      : String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected
                        ? borderColor
                        : AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
            if (_isAnswered && index == correctIndex)
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isAnswered ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentQuestion < widget.quiz.questions.length - 1
                  ? 'Siguiente'
                  : 'Ver Resultados',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final percentage = (_correctCount / widget.quiz.questions.length * 100).round();
    final sanctuary = context.read<SanctuaryProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: percentage >= 70
                        ? [AppColors.success, AppColors.biochemistryGreen]
                        : percentage >= 40
                            ? [AppColors.warning, AppColors.pharmacologyOrange]
                            : [AppColors.error, AppColors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_correctCount/${widget.quiz.questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                percentage >= 70
                    ? '¡Excelente trabajo!'
                    : percentage >= 40
                        ? 'Sigue practicando'
                        : 'Necesitas repasar',
                style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has ganado ${_correctCount * 5} XP para tu árbol',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${sanctuary.totalXp} XP',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
