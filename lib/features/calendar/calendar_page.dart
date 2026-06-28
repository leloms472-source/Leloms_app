import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isWeeklyView = true;

  final Map<String, dynamic> _upcomingExam = {
    'subject': 'Anatomía',
    'topic': 'Sistema Cardiovascular',
    'daysLeft': 3,
    'date': 'Viernes 14',
  };

  final List<Map<String, dynamic>> _todaySchedule = [
    {
      'time': '08:00',
      'subject': 'Anatomía',
      'room': 'Aula 201',
      'type': 'Clase',
      'color': const Color(0xFFEF4444),
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'time': '10:00',
      'subject': 'Fisiología',
      'room': 'Lab 105',
      'type': 'Laboratorio',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.favorite_rounded,
    },
    {
      'time': '14:00',
      'subject': 'Farmacología',
      'room': 'Aula 105',
      'type': 'Clase',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.medication_rounded,
    },
    {
      'time': '18:00',
      'subject': 'Estudiar Cardio',
      'room': 'Biblioteca',
      'type': 'Estudio',
      'color': const Color(0xFF10B981),
      'icon': Icons.auto_stories_rounded,
    },
    {
      'time': '23:59',
      'subject': 'Entrega Reporte',
      'room': 'Virtual',
      'type': 'Tarea',
      'color': const Color(0xFFEF4444),
      'icon': Icons.assignment_rounded,
    },
  ];

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Quiz Bioquímica',
      'date': 'Viernes 14',
      'type': 'Examen',
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Parcial Fisiología',
      'date': 'Lunes 17',
      'type': 'Examen',
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Entrega Mapa Mental',
      'date': 'Martes 18',
      'type': 'Tarea',
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agregar evento - Próximamente')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamAlert(),
            const SizedBox(height: 20),
            _buildViewToggle(),
            const SizedBox(height: 20),
            _buildDateHeader(),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 24),
            _buildUpcomingEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Examen Próximo!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_upcomingExam['subject']} - ${_upcomingExam['topic']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Faltan ${_upcomingExam['daysLeft']} días (${_upcomingExam['date']})',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeeklyView = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isWeeklyView ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Semana',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isWeeklyView ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeeklyView = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isWeeklyView ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isWeeklyView ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoy',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
            Text(
              'Miércoles 12',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF151B2E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_rounded, size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              const Text('5 eventos', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: _todaySchedule.map((item) => _buildTimelineItem(item)).toList(),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: item['color'], width: 4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              item['time'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item['color'].withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], color: item['color'], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['subject'],
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(item['room'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(width: 12),
                    Text(item['type'], style: TextStyle(color: item['color'], fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Próximos Eventos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todo', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._upcomingEvents.map((event) => _buildUpcomingEventItem(event)).toList(),
      ],
    );
  }

  Widget _buildUpcomingEventItem(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: event['color'],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
                ),
                Text(
                  event['date'],
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: event['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event['type'],
              style: TextStyle(color: event['color'], fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
