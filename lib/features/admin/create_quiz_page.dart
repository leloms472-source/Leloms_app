import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/content_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/models/quiz_model.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final ContentRepository _contentRepo = ContentRepository();
  final _titleCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '10');
  String _selectedSubject = 'Anatomía';
  String _selectedDifficulty = 'Intermedio';
  final List<_QuestionForm> _questions = [_QuestionForm()];
  final List<String> _subjects = const [
    'Anatomía', 'Fisiología', 'Bioquímica', 'Farmacología', 'Histología', 'Patología',
  ];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _timeCtrl.dispose();
    for (final q in _questions) { q.dispose(); }
    super.dispose();
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuestionForm()));
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    _questions[index].dispose();
    setState(() => _questions.removeAt(index));
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un título'), backgroundColor: AppColors.error));
      return;
    }

    final questionsData = <QuizQuestion>[];
    for (final q in _questions) {
      final question = q.questionCtrl.text.trim();
      final opt1 = q.opt1Ctrl.text.trim();
      final opt2 = q.opt2Ctrl.text.trim();
      final opt3 = q.opt3Ctrl.text.trim();
      final opt4 = q.opt4Ctrl.text.trim();
      if (question.isEmpty || opt1.isEmpty || opt2.isEmpty || opt3.isEmpty || opt4.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todas las preguntas y opciones'), backgroundColor: AppColors.error));
        return;
      }
      questionsData.add(QuizQuestion(
        question: question,
        options: [opt1, opt2, opt3, opt4],
        correctIndex: q.correctIndex,
        explanation: q.explanationCtrl.text.trim().isEmpty ? null : q.explanationCtrl.text.trim(),
      ));
    }

    setState(() => _saving = true);

    try {
      final quiz = Quiz(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthRepository().currentUser?.id,
        title: _titleCtrl.text.trim(),
        subject: _selectedSubject,
        difficulty: _selectedDifficulty,
        questions: questionsData,
        timeMinutes: int.tryParse(_timeCtrl.text) ?? 10,
      );
      await _contentRepo.addQuiz(quiz);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Quiz creado exitosamente!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Crear Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, color: AppColors.primary),
            label: const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Información General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              const SizedBox(height: 12),
              TextField(controller: _titleCtrl, style: const TextStyle(color: AppColors.lightText), decoration: const InputDecoration(labelText: 'Título del Quiz', labelStyle: TextStyle(color: AppColors.secondaryText))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject, dropdownColor: AppColors.darkCard, style: const TextStyle(color: AppColors.lightText),
                decoration: const InputDecoration(labelText: 'Asignatura', labelStyle: TextStyle(color: AppColors.secondaryText)),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty, dropdownColor: AppColors.darkCard, style: const TextStyle(color: AppColors.lightText),
                decoration: const InputDecoration(labelText: 'Dificultad', labelStyle: TextStyle(color: AppColors.secondaryText)),
                items: const ['Básico', 'Intermedio', 'Avanzado'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedDifficulty = v ?? _selectedDifficulty),
              ),
              const SizedBox(height: 12),
              TextField(controller: _timeCtrl, style: const TextStyle(color: AppColors.lightText), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tiempo (minutos)', labelStyle: TextStyle(color: AppColors.secondaryText))),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            const Text('Preguntas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const Spacer(),
            Text('${_questions.length}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary), onPressed: _addQuestion),
          ]),
          ..._questions.asMap().entries.map((entry) => _buildQuestionCard(entry.key, entry.value)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, _QuestionForm q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.2)), child: Center(child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)))),
          const Spacer(),
          if (_questions.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20), onPressed: () => _removeQuestion(index)),
        ]),
        const SizedBox(height: 8),
        TextField(controller: q.questionCtrl, style: const TextStyle(color: AppColors.lightText), maxLines: 3, decoration: const InputDecoration(labelText: 'Pregunta', labelStyle: TextStyle(color: AppColors.secondaryText), hintText: 'Escribe la pregunta aquí...', hintStyle: TextStyle(color: AppColors.secondaryText))),
        const SizedBox(height: 12),
        ...List.generate(4, (i) => _buildOptionField(q, i)),
        const SizedBox(height: 8),
        TextField(controller: q.explanationCtrl, style: const TextStyle(color: AppColors.lightText), maxLines: 2, decoration: const InputDecoration(labelText: 'Explicación (opcional)', labelStyle: TextStyle(color: AppColors.secondaryText))),
      ]),
    );
  }

  Widget _buildOptionField(_QuestionForm q, int index) {
    const letters = ['A', 'B', 'C', 'D'];
    final isCorrect = q.correctIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => setState(() => q.correctIndex = index),
          child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: isCorrect ? AppColors.success : AppColors.darkCard, border: Border.all(color: isCorrect ? AppColors.success : AppColors.border)), child: Center(child: Text(letters[index], style: TextStyle(color: isCorrect ? Colors.white : AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)))),
        ),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: _optionCtrl(q, index), style: const TextStyle(color: AppColors.lightText, fontSize: 13), decoration: InputDecoration(hintText: 'Opción ${letters[index]}', hintStyle: const TextStyle(color: AppColors.secondaryText), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
      ]),
    );
  }

  TextEditingController _optionCtrl(_QuestionForm q, int index) {
    switch (index) {
      case 0: return q.opt1Ctrl;
      case 1: return q.opt2Ctrl;
      case 2: return q.opt3Ctrl;
      case 3: return q.opt4Ctrl;
      default: return q.opt1Ctrl;
    }
  }
}

class _QuestionForm {
  final questionCtrl = TextEditingController();
  final opt1Ctrl = TextEditingController();
  final opt2Ctrl = TextEditingController();
  final opt3Ctrl = TextEditingController();
  final opt4Ctrl = TextEditingController();
  final explanationCtrl = TextEditingController();
  int correctIndex = 0;

  void dispose() {
    questionCtrl.dispose();
    opt1Ctrl.dispose();
    opt2Ctrl.dispose();
    opt3Ctrl.dispose();
    opt4Ctrl.dispose();
    explanationCtrl.dispose();
  }
}
