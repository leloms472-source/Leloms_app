import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../models/study_plan.dart';

class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({super.key});

  @override
  State<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  StudyPlan? _plan;
  bool _showGenerator = false;

  final TextEditingController _examTitleCtrl = TextEditingController();
  final TextEditingController _hoursCtrl = TextEditingController(text: '2');
  DateTime _examDate = DateTime.now().add(const Duration(days: 30));
  final List<String> _selectedSubjects = [];
  final List<String> _availableSubjects = [
    'Anatomía', 'Fisiología', 'Bioquímica', 'Farmacología', 'Histología', 'Patología',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('study_plan');
    if (stored != null) {
      try {
        final data = jsonDecode(stored) as Map<String, dynamic>;
        _plan = StudyPlan.fromMap('saved', data);
        if (mounted) setState(() {});
      } catch (_) {}
    }
  }

  Future<void> _savePlan(StudyPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('study_plan', jsonEncode(plan.toMap()));
    setState(() {
      _plan = plan;
      _showGenerator = false;
    });
  }

  Future<void> _deletePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('study_plan');
    setState(() => _plan = null);
  }

  void _generatePlan() {
    if (_examTitleCtrl.text.isEmpty || _selectedSubjects.isEmpty) return;

    final plan = StudyPlanGenerator.generate(
      examTitle: _examTitleCtrl.text,
      examDate: _examDate,
      subjects: _selectedSubjects,
      hoursPerDay: int.tryParse(_hoursCtrl.text) ?? 2,
    );

    _savePlan(plan);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan creado: ${plan.totalDays} días de estudio'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _examTitleCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Plan de Estudio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_plan != null && !_showGenerator)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: () => setState(() => _showGenerator = true),
            ),
        ],
      ),
      body: _showGenerator ? _buildGenerator() : (_plan != null ? _buildPlanView() : _buildEmptyState()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.calendar_month_rounded, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('Crea tu Plan de Estudio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 8),
          const Text('Selecciona tu examen y materias\ny genera un plan personalizado', style: TextStyle(color: AppColors.secondaryText, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showGenerator = true),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Crear Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.secondary.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configura tu Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                const SizedBox(height: 16),
                TextField(
                  controller: _examTitleCtrl,
                  style: const TextStyle(color: AppColors.lightText),
                  decoration: InputDecoration(
                    labelText: 'Nombre del examen',
                    hintText: 'Ej: ENARM 2026',
                    labelStyle: const TextStyle(color: AppColors.secondaryText),
                    hintStyle: const TextStyle(color: AppColors.secondaryText),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _examDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)), child: child!),
                    );
                    if (date != null) setState(() => _examDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text('Fecha del examen: ${_examDate.day}/${_examDate.month}/${_examDate.year}', style: const TextStyle(color: AppColors.lightText)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hoursCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.lightText),
                  decoration: InputDecoration(
                    labelText: 'Horas de estudio por día',
                    labelStyle: const TextStyle(color: AppColors.secondaryText),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Materias a incluir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSubjects.map((subject) {
              final selected = _selectedSubjects.contains(subject);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) _selectedSubjects.remove(subject);
                  else _selectedSubjects.add(subject);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.check_rounded, color: AppColors.primary, size: 16)),
                      Text(subject, style: TextStyle(color: selected ? AppColors.primary : AppColors.lightText, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _selectedSubjects.isNotEmpty && _examTitleCtrl.text.isNotEmpty ? _generatePlan : null,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generar Plan de Estudio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanView() {
    final plan = _plan!;
    final remainingDays = plan.examDate.difference(DateTime.now()).inDays;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayPlan = plan.days.where((d) =>
      d.date.year == today.year && d.date.month == today.month && d.date.day == today.day
    ).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.success.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withValues(alpha: 0.2)),
                  child: const Icon(Icons.checklist_rounded, color: AppColors.success, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.examTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                      Text('Faltan $remainingDays días • ${plan.totalDays} días de plan', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${plan.completedDays} días completados', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              Text('${(plan.progress * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 24),
          if (todayPlan != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: todayPlan.isComplete ? AppColors.success.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                      const Spacer(),
                      if (todayPlan.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Completado', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      else
                        TextButton.icon(
                          onPressed: () {
                            setState(() => todayPlan.isComplete = true);
                            _savePlan(plan);
                          },
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Completar'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...todayPlan.topics.map((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: topic.isDone ? AppColors.success.withValues(alpha: 0.2) : AppColors.info.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            topic.isDone ? Icons.check_rounded : Icons.menu_book_rounded,
                            color: topic.isDone ? AppColors.success : AppColors.info,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(topic.topic, style: TextStyle(color: AppColors.lightText, fontSize: 13, fontWeight: topic.isDone ? FontWeight.normal : FontWeight.w600)),
                        ),
                        Text('${topic.hours}h', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Próximos días', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 12),
          ...plan.days.take(7).map((day) {
            final isPast = day.date.isBefore(today);
            final isToday = day.date == today;
            if (isToday || isPast) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: day.isComplete ? AppColors.success.withValues(alpha: 0.2) : AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.isComplete ? AppColors.success.withValues(alpha: 0.2) : AppColors.border,
                    ),
                    child: Center(
                      child: Text('${day.date.day}', style: TextStyle(
                        color: day.isComplete ? AppColors.success : AppColors.lightText,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${day.date.day}/${day.date.month}', style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${day.topics.length} temas • ${day.topics.fold(0, (sum, t) => sum + t.hours)}h', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (day.isComplete)
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deletePlan,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar Plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
