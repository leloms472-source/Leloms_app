import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exam.dart';
import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../services/firestore_service.dart';

class ExamPage extends StatefulWidget {
  final ExamConfig config;
  const ExamPage({super.key, required this.config});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with TickerProviderStateMixin {
  final List<ExamQuestionResult> _results = [];
  Timer? _timer;
  int _secondsRemaining;
  final List<_ExamQuestion> _questions = [];
  int _currentIndex = 0;
  int _selectedAnswer = -1;
  bool _isAnswered = false;
  bool _isFinished = false;
  final Map<int, int> _questionTimes = {};
  final Random _random = Random();
  late AnimationController _warningAnim;

  _ExamPageState() : _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.config.timeMinutes * 60;
    _warningAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final firestore = FirestoreService();
    firestore.getQuizzes().then((quizzes) {
      if (quizzes.isEmpty) return;
      if (!mounted) return;
      final allQuestions = <_ExamQuestion>[];
      for (final quiz in quizzes) {
        for (final q in quiz.questions) {
          allQuestions.add(_ExamQuestion(
            question: q.question,
            options: List.from(q.options),
            correctIndex: q.correctIndex,
            subject: quiz.subject,
          ));
        }
      }
      allQuestions.shuffle(_random);

      final selected = allQuestions.take(widget.config.totalQuestions).toList();
      setState(() => _questions.addAll(selected));
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        _finishExam();
      } else {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 60) _warningAnim.forward();
        });
      }
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    _questionTimes[_currentIndex] = (widget.config.timeMinutes * 60) - _secondsRemaining;
    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (_currentIndex < widget.config.totalQuestions - 1) {
        setState(() {
          final q = _questions[_currentIndex];
          _results.add(ExamQuestionResult(
            question: q.question,
            subject: q.subject,
            selectedAnswer: _selectedAnswer,
            correctAnswer: q.correctIndex,
            timeSpent: _questionTimes[_currentIndex] ?? 0,
            isCorrect: _selectedAnswer == q.correctIndex,
          ));
          _currentIndex++;
          _selectedAnswer = -1;
          _isAnswered = false;
        });
      } else {
        final q = _questions[_currentIndex];
        _results.add(ExamQuestionResult(
          question: q.question,
          subject: q.subject,
          selectedAnswer: _selectedAnswer,
          correctAnswer: q.correctIndex,
          timeSpent: _questionTimes[_currentIndex] ?? 0,
          isCorrect: _selectedAnswer == q.correctIndex,
        ));
        _finishExam();
      }
    });
  }

  void _finishExam() {
    _timer?.cancel();
    if (_currentIndex < _questions.length) {
      for (int i = _currentIndex; i < _questions.length; i++) {
        final q = _questions[i];
        _results.add(ExamQuestionResult(
          question: q.question,
          subject: q.subject,
          selectedAnswer: -1,
          correctAnswer: q.correctIndex,
          timeSpent: 0,
          isCorrect: false,
        ));
      }
    }

    final correctCount = _results.where((r) => r.isCorrect).length;
    final subjectCorrect = <String, int>{};
    final subjectTotal = <String, int>{};
    for (final r in _results) {
      subjectCorrect[r.subject] = (subjectCorrect[r.subject] ?? 0) + (r.isCorrect ? 1 : 0);
      subjectTotal[r.subject] = (subjectTotal[r.subject] ?? 0) + 1;
    }

    final xpGained = correctCount * 10;
    context.read<UserProvider>().addXp(xpGained);
    context.read<SanctuaryProvider>().addXp(xpGained);

    final achievements = context.read<AchievementProvider>();
    achievements.tryUnlock(AchievementId.firstQuiz);

    if (!mounted) return;
    setState(() => _isFinished = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _warningAnim.dispose();
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

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.dark,
        appBar: AppBar(
          title: const Text('Simulacro'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.config.totalQuestions;
    final isLowTime = _secondsRemaining < 60;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Pregunta ${_currentIndex + 1}/${widget.config.totalQuestions}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.darkCard,
                title: const Text('¿Salir del simulacro?', style: const TextStyle(color: AppColors.lightText)),
                content: const Text('Perderás todo el progreso', style: const TextStyle(color: AppColors.secondaryText)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuar', style: const TextStyle(color: AppColors.primary))),
                  TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Salir', style: const TextStyle(color: AppColors.error))),
                ],
              ),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _warningAnim,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLowTime
                      ? AppColors.error.withValues(alpha: 0.2 + (_warningAnim.value * 0.2))
                      : AppColors.darkCard,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  _formattedTime,
                  style: TextStyle(
                    color: isLowTime ? AppColors.error : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          ClipRRect(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.darkCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowTime ? AppColors.error : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      question.subject,
                      style: const TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: const TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ...question.options.asMap().entries.map((entry) =>
                      _buildOption(entry.key, entry.value, question.correctIndex)),
                ],
              ),
            ),
          ),
          _buildProgressDots(),
        ],
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
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? borderColor.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(color: isSelected ? borderColor : AppColors.secondaryText, width: 2),
              ),
              child: Center(
                child: Text(
                  _isAnswered && index == correctIndex ? '✓' : String.fromCharCode(65 + index),
                  style: TextStyle(color: isSelected ? borderColor : AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 14, height: 1.3))),
            if (_isAnswered && index == correctIndex)
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.config.totalQuestions > 20 ? 20 : widget.config.totalQuestions,
          (i) {
            final isActive = i == _currentIndex;
            final isDone = i < _currentIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: isActive ? AppColors.primary : (isDone ? AppColors.success : AppColors.border),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults() {
    final correctCount = _results.where((r) => r.isCorrect).length;
    final pct = widget.config.totalQuestions > 0 ? (correctCount / widget.config.totalQuestions * 100).round() : 0;
    final timeSpent = (widget.config.timeMinutes * 60) - _secondsRemaining;
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;

    final subjectCorrect = <String, int>{};
    final subjectTotal = <String, int>{};
    for (final r in _results) {
      subjectCorrect[r.subject] = (subjectCorrect[r.subject] ?? 0) + (r.isCorrect ? 1 : 0);
      subjectTotal[r.subject] = (subjectTotal[r.subject] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreCircle(pct, correctCount),
            const SizedBox(height: 24),
            _buildStatsRow(minutes, seconds, correctCount),
            const SizedBox(height: 24),
            _buildSubjectBreakdown(subjectCorrect, subjectTotal),
            const SizedBox(height: 24),
            _buildAnswerReview(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                child: const Text('Finalizar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(int pct, int correct) {
    Color color;
    if (pct >= 80) { color = AppColors.success; }
    else if (pct >= 60) { color = AppColors.warning; }
    else { color = AppColors.error; }

    return Container(
      width: 160, height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          Text('$correct/${widget.config.totalQuestions}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int minutes, int seconds, int correct) {
    final xpGained = correct * 10;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.access_time_rounded, '${minutes}m ${seconds}s', 'Tiempo'),
          _buildStatItem(Icons.check_circle_rounded, '$correct', 'Correctas'),
          _buildStatItem(Icons.stars_rounded, '+$xpGained XP', 'Ganados'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
      ],
    );
  }

  Widget _buildSubjectBreakdown(Map<String, int> subjectCorrect, Map<String, int> subjectTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desempeño por Materia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 16),
          ...subjectTotal.entries.map((entry) {
            final correct = subjectCorrect[entry.key] ?? 0;
            final total = entry.value;
            final pct = total > 0 ? correct / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(color: AppColors.lightText, fontSize: 13)),
                      Text('$correct/$total', style: TextStyle(
                        color: pct >= 0.7 ? AppColors.success : (pct >= 0.5 ? AppColors.warning : AppColors.error),
                        fontWeight: FontWeight.bold, fontSize: 13,
                      )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 0.7 ? AppColors.success : (pct >= 0.5 ? AppColors.warning : AppColors.error),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnswerReview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revisión Rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _results.asMap().entries.map((entry) {
              final r = entry.value;
              return Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: r.isCorrect
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      color: r.isCorrect ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ExamQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String subject;

  const _ExamQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.subject,
  });
}
