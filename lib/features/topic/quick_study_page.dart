import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_service.dart';
import '../../models/flashcard.dart';
import '../flashcard/flashcard_page.dart';
import '../../widgets/leloms_cat.dart';

class QuickStudyPage extends StatefulWidget {
  final int duration;
  const QuickStudyPage({super.key, required this.duration});

  @override
  State<QuickStudyPage> createState() => _QuickStudyPageState();
}

class _QuickStudyPageState extends State<QuickStudyPage> {
  final AiService _ai = AiService();
  String _phase = 'select';
  String? _topic;
  final TextEditingController _topicController = TextEditingController();
  String? _summary;
  List<String> _flashcards = [];
  List<_QuickQuizQuestion> _quiz = [];
  int _quizIndex = 0;
  String? _selectedAnswer;
  int _correctCount = 0;
  bool _showResult = false;
  bool _loading = false;

  bool get isTenMin => widget.duration == 10;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _startStudy() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    _topic = topic;
    setState(() { _loading = true; _phase = 'generating'; });

    if (isTenMin) {
      await _generateQuickSession(topic);
    } else {
      await _generateFullSession(topic);
    }

    if (mounted) setState(() { _loading = false; _phase = 'summary'; });
  }

  Future<void> _generateQuickSession(String topic) async {
    final summaryRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Haz un resumen muy conciso (3-5 líneas) sobre "$topic". Puntos clave solamente.'},
    ]);
    final flashcardsRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Crea 5 flashcards sobre "$topic". Formato: "Pregunta|Respuesta". Separa cada flashcard con "---".'},
    ]);
    final quizRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Crea 3 preguntas de opción múltiple sobre "$topic". Formato por pregunta: "Pregunta|Opción A|Opción B|Opción C|Correcta(A/B/C)". Separa con "---".'},
    ]);

    setState(() {
      _summary = summaryRes;
      _flashcards = flashcardsRes.split('---').map((e) => e.trim()).where((e) => e.contains('|')).toList();
      _quiz = _parseQuiz(quizRes);
    });
  }

  Future<void> _generateFullSession(String topic) async {
    final summaryRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Escribe un resumen detallado sobre "$topic". Cubre conceptos clave, ejemplos, y aplicaciones. Extensión: 1 párrafo.'},
    ]);
    final flashcardsRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Crea 8 flashcards sobre "$topic". Formato: "Pregunta|Respuesta". Separa con "---".'},
    ]);
    final quizRes = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': 'Crea 5 preguntas de opción múltiple desafiantes sobre "$topic". Formato: "Pregunta|Opción A|Opción B|Opción C|Correcta(A/B/C)". Separa con "---".'},
    ]);

    setState(() {
      _summary = summaryRes;
      _flashcards = flashcardsRes.split('---').map((e) => e.trim()).where((e) => e.contains('|')).toList();
      _quiz = _parseQuiz(quizRes);
    });
  }

  List<_QuickQuizQuestion> _parseQuiz(String text) {
    final questions = <_QuickQuizQuestion>[];
    final parts = text.split('---');
    for (final part in parts) {
      final lines = part.trim().split('\n');
      if (lines.length < 5) continue;
      final question = lines[0].replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      if (question.isEmpty) continue;
      String? a, b, c, correct;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('A)') || trimmed.startsWith('A.')) a = trimmed.substring(2).trim();
        else if (trimmed.startsWith('B)') || trimmed.startsWith('B.')) b = trimmed.substring(2).trim();
        else if (trimmed.startsWith('C)') || trimmed.startsWith('C.')) c = trimmed.substring(2).trim();
        else if (trimmed.startsWith('Correcta')) correct = trimmed.split(RegExp(r'A|B|C'))[1].trim();
      }
      if (question.isNotEmpty && a != null && b != null && correct != null) {
        questions.add(_QuickQuizQuestion(question, a, b, c, correct));
      }
    }
    if (questions.isEmpty) {
      final lines = text.split('\n');
      for (int i = 0; i < lines.length; i += 5) {
        if (i + 4 < lines.length) {
          questions.add(_QuickQuizQuestion(
            lines[i].replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim(),
            lines[i + 1].replaceAll(RegExp(r'^[A-Z][\)\.]\s*'), '').trim(),
            lines[i + 2].replaceAll(RegExp(r'^[A-Z][\)\.]\s*'), '').trim(),
            lines[i + 3].replaceAll(RegExp(r'^[A-Z][\)\.]\s*'), '').trim(),
            lines[i + 4].replaceAll(RegExp(r'^Correcta\s*'), '').trim(),
          ));
        }
      }
    }
    return questions;
  }

  void _answerQuiz(String answer) {
    setState(() {
      _selectedAnswer = answer;
      if (answer == _quiz[_quizIndex].correct) _correctCount++;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_quizIndex < _quiz.length - 1) {
          _quizIndex++;
          _selectedAnswer = null;
        } else {
          _showResult = true;
          _phase = 'quiz_result';
        }
      });
    });
  }

  void _startPhase(String phase) {
    setState(() => _phase = phase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(isTenMin ? 'Estudio Rápido (10 min)' : 'Estudio Completo (1 hora)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_phase == 'select' || _phase == 'generating') return _buildSelectPhase();
    if (_phase == 'summary') return _buildSummaryPhase();
    if (_phase == 'flashcards') return _buildFlashcardsPhase();
    if (_phase == 'quiz' || _phase == 'quiz_result') return _buildQuizPhase();
    return _buildDonePhase();
  }

  Widget _buildSelectPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LelomsCatBanner(message: isTenMin
            ? 'Sesión exprés: resumen + 5 flashcards + quiz rápido'
            : 'Sesión completa: resumen detallado + 8 flashcards + quiz completo'),
        const SizedBox(height: 24),
        const Text('¿Qué tema estudiarás?', style: TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
          child: TextField(
            controller: _topicController,
            style: const TextStyle(color: AppColors.lightText),
            decoration: const InputDecoration(
              hintText: 'Ej: Sistema respiratorio, Farmacología...',
              hintStyle: TextStyle(color: AppColors.secondaryText),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _startStudy,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_loading ? 'Generando contenido...' : 'Comenzar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_loading) ...[
          const SizedBox(height: 20),
          const Center(child: Text('Leloms está preparando tu sesión de estudio...', style: TextStyle(color: AppColors.secondaryText))),
        ],
      ]),
    );
  }

  Widget _buildSummaryPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
            child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          const Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.biochemistryGreen.withValues(alpha: 0.2))),
          child: Text(_summary ?? '', style: const TextStyle(color: AppColors.lightText, fontSize: 14, height: 1.5)),
        ),
        const SizedBox(height: 20),
        _buildPhaseNavigation(),
      ]),
    );
  }

  Widget _buildFlashcardsPhase() {
    if (_flashcards.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('No se generaron flashcards', style: TextStyle(color: AppColors.secondaryText)),
          const SizedBox(height: 16),
          _buildPhaseNavigation(),
        ]),
      );
    }

    final cards = _flashcards.map((f) {
      final parts = f.split('|');
      return Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + parts[0].hashCode.toString(),
        front: parts[0].trim(),
        back: parts.length > 1 ? parts[1].trim() : '',
        subject: _topic ?? '',
      );
    }).toList();

    return Column(children: [
      Expanded(child: FlashcardPage(flashcards: cards, title: _topic ?? 'Flashcards')),
      Padding(
        padding: const EdgeInsets.all(16),
        child: _buildPhaseNavigation(),
      ),
    ]);
  }

  Widget _buildQuizPhase() {
    if (_quiz.isEmpty || _showResult) {
      return _buildQuizResult();
    }

    final q = _quiz[_quizIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Text('${_quizIndex + 1}/${_quiz.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Text('Quiz rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        ]),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14)),
          child: Text(q.question, style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 16),
        _quizOption('A', q.a, q.correct == 'A'),
        _quizOption('B', q.b, q.correct == 'B'),
        if (q.c != null) _quizOption('C', q.c!, q.correct == 'C'),
      ]),
    );
  }

  Widget _quizOption(String letter, String text, bool isCorrect) {
    final isSelected = _selectedAnswer == letter;
    Color borderColor;
    Color bgColor;
    if (_selectedAnswer == null) {
      borderColor = AppColors.border;
      bgColor = AppColors.darkCard;
    } else if (isSelected) {
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      bgColor = isCorrect ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1);
    } else if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
    } else {
      borderColor = AppColors.border;
      bgColor = AppColors.darkCard;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectedAnswer == null ? () => _answerQuiz(letter) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor.withValues(alpha: 0.15)),
                child: Center(child: Text(letter, style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(color: AppColors.lightText, fontSize: 14))),
              if (_selectedAnswer != null && isCorrect)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              if (_selectedAnswer != null && isSelected && !isCorrect)
                const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizResult() {
    final pct = _quiz.isEmpty ? 0 : (_correctCount / _quiz.length * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pct >= 70 ? AppColors.success.withValues(alpha: 0.15) : AppColors.pharmacologyOrange.withValues(alpha: 0.15),
            ),
            child: Icon(pct >= 70 ? Icons.emoji_events_rounded : Icons.replay_rounded, color: pct >= 70 ? AppColors.success : AppColors.pharmacologyOrange, size: 48),
          ),
          const SizedBox(height: 20),
          Text('$pct% correcto', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 8),
          Text('$_correctCount de ${_quiz.length} preguntas', style: const TextStyle(color: AppColors.secondaryText, fontSize: 16)),
          const SizedBox(height: 24),
          _buildPhaseNavigation(),
        ]),
      ),
    );
  }

  Widget _buildDonePhase() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const LelomsCat(message: '¡Buen trabajo! Sigue así.', size: 50),
          const SizedBox(height: 24),
          Text('Sesión de ${isTenMin ? "10 min" : "1 hora"} completada', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Volver al inicio'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    );
  }

  Widget _buildPhaseNavigation() {
    final phases = isTenMin
        ? ['summary', 'flashcards', 'quiz']
        : ['summary', 'flashcards', 'quiz'];
    final labels = ['Resumen', 'Flashcards', 'Quiz'];
    final currentIdx = phases.indexOf(_phase);

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (currentIdx > 0)
          TextButton.icon(
            onPressed: () => _startPhase(phases[currentIdx - 1]),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Anterior'),
          ),
        const SizedBox(width: 16),
        if (currentIdx < phases.length - 1)
          ElevatedButton.icon(
            onPressed: () => _startPhase(phases[currentIdx + 1]),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(labels[currentIdx + 1]),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )
        else
          ElevatedButton.icon(
            onPressed: () => _startPhase('done'),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Finalizar'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
      ]),
    ]);
  }
}

class _QuickQuizQuestion {
  final String question;
  final String a;
  final String b;
  final String? c;
  final String correct;
  _QuickQuizQuestion(this.question, this.a, this.b, this.c, this.correct);
}
