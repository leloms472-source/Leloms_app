import 'package:flutter/material.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> with SingleTickerProviderStateMixin {
  int _selectedMood = 3;
  bool _isBreathing = false;
  late AnimationController _controller;
  String _tip = '';

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😫', 'label': 'Estresado', 'color': const Color(0xFFEF4444)},
    {'emoji': '😕', 'label': 'Agobiado', 'color': const Color(0xFFF97316)},
    {'emoji': '😐', 'label': 'Neutral', 'color': const Color(0xFFEAB308)},
    {'emoji': '🙂', 'label': 'Bien', 'color': const Color(0xFF10B981)},
    {'emoji': '🤩', 'label': 'Excelente', 'color': const Color(0xFF6366F1)},
  ];

  final List<String> _tips = [
    'Recuerda: No se trata de ser perfecto, sino de ser constante. Un día a la vez. 🌙',
    'Tu mente también necesita descansar. Tómate 5 minutos para respirar. ',
    'Cada pequeño paso cuenta. ¡Vas por buen camino! ✨',
    'El estudio es un maratón, no un sprint. Ve a tu propio ritmo. 🐢',
    'Hoy es un buen día para aprender algo nuevo. ¡Tú puedes! 💪',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _generateTip();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateTip() {
    setState(() {
      _tip = _tips[DateTime.now().millisecondsSinceEpoch % _tips.length];
    });
  }
  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(title: const Text('Bienestar'), actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildGreeting(),
          const SizedBox(height: 24),
          _buildMoodSelector(),
          const SizedBox(height: 24),
          _buildBreathingExercise(),
          const SizedBox(height: 24),
          _buildDailyTip(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ]),
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 15)],
      ),
      child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)), child: const Icon(Icons.self_improvement_rounded, size: 35, color: Colors.white)),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cuida tu mente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
          Text('Tu bienestar es tan importante como estudiar', style: TextStyle(color: Colors.white70)),
        ])),      ]),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF151B2E), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.mood_rounded, color: Color(0xFFD4AF37)), const SizedBox(width: 8), const Text('¿Cómo te sientes hoy?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)))]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(_moods.length, (index) => _buildMoodButton(index))),
      ]),
    );
  }

  Widget _buildMoodButton(int index) {
    final mood = _moods[index];
    final isSelected = _selectedMood == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? mood['color'] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : mood['color'], width: 2),
        ),
        child: Column(children: [
          Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(mood['label'], style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildBreathingExercise() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF151B2E), Color(0xFF1E2540)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.air_rounded, color: Color(0xFF6366F1)), const SizedBox(width: 8), const Text('Respiración guiada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))), const Spacer(), Switch(value: _isBreathing, onChanged: (_) => _toggleBreathing(), activeColor: const Color(0xFF6366F1))]),
        const SizedBox(height: 20),
        Center(          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _isBreathing ? (0.5 + 0.5 * (_controller.value * 2 - 1).abs()) : 1.0;
              return Container(
                width: 120 * value,
                height: 120 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3 * value), blurRadius: 20 * value)],
                ),
                child: const Icon(Icons.pets_rounded, size: 50, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(_isBreathing ? 'Inhala... Exhala...' : 'Toca el interruptor para comenzar', style: const TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD4AF37).withOpacity(0.2), Color(0xFFD4AF37).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.lightbulb_rounded, color: Color(0xFFD4AF37)), const SizedBox(width: 8), const Text('Consejo del día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))), const Spacer(), IconButton(icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)), onPressed: _generateTip)]),
        const SizedBox(height: 12),
        Text(_tip, style: const TextStyle(color: Color(0xFFE2E8F0), height: 1.6, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildQuickActions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acciones rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,        children: [
          _buildQuickAction(Icons.music_note_rounded, 'Música relajante', const Color(0xFF6366F1)),
          _buildQuickAction(Icons.bedtime_rounded, 'Recordatorio de sueño', const Color(0xFF8B5CF6)),
          _buildQuickAction(Icons.water_drop_rounded, 'Recordar hidratarse', const Color(0xFF06B6D4)),
          _buildQuickAction(Icons.timer_rounded, 'Pomodoro', const Color(0xFF10B981)),
        ],
      ),
    ]);
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF151B2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 32, color: color), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12), textAlign: TextAlign.center)]),
    );
  }
}
