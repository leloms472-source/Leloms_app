import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isWeeklyView = true;

  final Map<String, dynamic> _upcomingExam = {
    'subject': 'Anatomía', 'topic': 'Sistema Cardiovascular', 'daysLeft': 3, 'date': 'Viernes 14',
  };

  final List<Map<String, dynamic>> _todaySchedule = [
    {'time': '08:00', 'subject': 'Anatomía', 'room': 'Aula 201', 'type': 'Clase', 'color': AppColors.anatomyRed, 'icon': Icons.monitor_heart_rounded},
    {'time': '10:00', 'subject': 'Fisiología', 'room': 'Lab 105', 'type': 'Laboratorio', 'color': AppColors.physiologyBlue, 'icon': Icons.favorite_rounded},
    {'time': '14:00', 'subject': 'Farmacología', 'room': 'Aula 105', 'type': 'Clase', 'color': AppColors.pharmacologyOrange, 'icon': Icons.medication_rounded},
    {'time': '18:00', 'subject': 'Estudiar Cardio', 'room': 'Biblioteca', 'type': 'Estudio', 'color': AppColors.biochemistryGreen, 'icon': Icons.auto_stories_rounded},
    {'time': '23:59', 'subject': 'Entrega Reporte', 'room': 'Virtual', 'type': 'Tarea', 'color': AppColors.anatomyRed, 'icon': Icons.assignment_rounded},
  ];

  final List<Map<String, dynamic>> _upcomingEvents = [
    {'title': 'Quiz Bioquímica', 'date': 'Viernes 14', 'type': 'Examen', 'color': AppColors.anatomyRed},
    {'title': 'Parcial Fisiología', 'date': 'Lunes 17', 'type': 'Examen', 'color': AppColors.anatomyRed},
    {'title': 'Entrega Mapa Mental', 'date': 'Martes 18', 'type': 'Tarea', 'color': AppColors.physiologyBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Agregar evento - Próximamente')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildExamAlert(),
          const SizedBox(height: 20),
          _buildViewToggle(),
          const SizedBox(height: 20),
          _buildDateHeader(),
          const SizedBox(height: 16),
          _buildTimeline(),
          const SizedBox(height: 24),
          _buildUpcomingEvents(),
        ]),
      ),
    );
  }

  Widget _buildExamAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.error, AppColors.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¡Examen Próximo!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${_upcomingExam['subject']} - ${_upcomingExam['topic']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Faltan ${_upcomingExam['daysLeft']} días (${_upcomingExam['date']})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Row(children: [
        _buildToggleOption('Semana', _isWeeklyView, () => setState(() => _isWeeklyView = true)),
        _buildToggleOption('Mes', !_isWeeklyView, () => setState(() => _isWeeklyView = false)),
      ]),
    );
  }

  Widget _buildToggleOption(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hoy', style: TextStyle(fontSize: 14, color: AppColors.secondaryText)),
        Text('Miércoles 12', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      ]),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text('5 eventos', style: TextStyle(color: AppColors.lightText, fontSize: 12)),
        ]),
      ),
    ]);
  }

  Widget _buildTimeline() {
    return Column(children: _todaySchedule.map((item) => _buildTimelineItem(item)).toList());
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border(left: BorderSide(color: item['color'] as Color, width: 4)),
      ),
      child: Row(children: [
        SizedBox(width: 50, child: Text(item['time'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
        const SizedBox(width: 16),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, color: (item['color'] as Color).withValues(alpha: 0.2)),
          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['subject'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.secondaryText),
            const SizedBox(width: 4),
            Text(item['room'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(width: 12),
            Text(item['type'] as String, style: TextStyle(color: item['color'] as Color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Text('Próximos Eventos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        Spacer(),
        Text('Ver todo', style: TextStyle(color: AppColors.primary)),
      ]),
      const SizedBox(height: 12),
      ..._upcomingEvents.map((event) => _buildUpcomingEventItem(event)),
    ]);
  }

  Widget _buildUpcomingEventItem(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(children: [
        Container(width: 8, height: 40, decoration: BoxDecoration(color: event['color'] as Color, borderRadius: const BorderRadius.all(Radius.circular(4)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightText)),
          Text(event['date'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: (event['color'] as Color).withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: Text(event['type'] as String, style: TextStyle(color: event['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
