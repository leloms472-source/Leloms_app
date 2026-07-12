import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exam.dart';
import 'exam_page.dart';

class ExamConfigPage extends StatefulWidget {
  const ExamConfigPage({super.key});

  @override
  State<ExamConfigPage> createState() => _ExamConfigPageState();
}

class _ExamConfigPageState extends State<ExamConfigPage> {
  final List<String> _availableSubjects = [
    'Anatomía', 'Fisiología', 'Bioquímica', 'Farmacología', 'Histología', 'Patología',
  ];
  final Set<String> _selectedSubjects = {};
  int _questionCount = 20;
  int _timeMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Simulacro de Examen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSubjectSelector(),
            const SizedBox(height: 24),
            _buildSliderConfig('Cantidad de preguntas', _questionCount, 5, 60, 5, (v) => setState(() => _questionCount = v)),
            const SizedBox(height: 16),
            _buildSliderConfig('Tiempo límite (minutos)', _timeMinutes, 5, 120, 5, (v) => setState(() => _timeMinutes = v)),
            const SizedBox(height: 24),
            _buildSummary(),
            const SizedBox(height: 24),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error.withValues(alpha: 0.15), AppColors.pharmacologyOrange.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.error.withValues(alpha: 0.2)),
            child: const Icon(Icons.assignment_rounded, color: AppColors.error, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Modo Examen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                SizedBox(height: 4),
                Text('Simula condiciones reales de examen\nSin retroceder • Temporizador • Aleatorio', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Materias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSubjects.map((subject) {
            final selected = _selectedSubjects.contains(subject);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedSubjects.remove(subject);
                  } else {
                    _selectedSubjects.add(subject);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.darkCard,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected)
                      const Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                      ),
                    Text(subject, style: TextStyle(color: selected ? AppColors.primary : AppColors.lightText, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderConfig(String label, int value, int min, int max, int divisions, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              Text('$value', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ 5,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final config = ExamConfig(
      subjects: _selectedSubjects.toList(),
      totalQuestions: _questionCount,
      timeMinutes: _timeMinutes,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('${_selectedSubjects.length}', 'Materias'),
          _buildSummaryItem('$_questionCount', 'Preguntas'),
          _buildSummaryItem('$_timeMinutes min', 'Tiempo'),
          _buildSummaryItem(config.difficulty, 'Dificultad'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
      ],
    );
  }

  Widget _buildStartButton() {
    final canStart = _selectedSubjects.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canStart
            ? () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ExamPage(
                  config: ExamConfig(
                    subjects: _selectedSubjects.toList(),
                    totalQuestions: _questionCount,
                    timeMinutes: _timeMinutes,
                  ),
                ),
              ))
            : null,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Comenzar Simulacro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(16))),
        ),
      ),
    );
  }
}
