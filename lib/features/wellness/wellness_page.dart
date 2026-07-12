import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  int _selectedMood = -1;
  bool _isBreathing = false;
  int _breathingPhase = 0;
  Timer? _breathingTimer;
  String _currentTip = '';
  double _energyLevel = 7.0;
  int _sleepHours = 8;

  final int _wellnessStreak = 5;
  final int _breathingSessions = 3;
  final String _averageMood = 'Bien';

  final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Estresado', 'color': AppColors.error},
    {'icon': Icons.sentiment_dissatisfied, 'label': 'Agobiado', 'color': AppColors.tertiary},
    {'icon': Icons.sentiment_neutral, 'label': 'Neutral', 'color': AppColors.warning},
    {'icon': Icons.sentiment_satisfied, 'label': 'Bien', 'color': AppColors.success},
    {'icon': Icons.sentiment_very_satisfied, 'label': 'Excelente', 'color': AppColors.primary},
  ];

  final List<String> _tips = [
    'Tu carrera está al alcance de una lágrima. Tómate un descanso cuando lo necesites.',
    'Estudia 25 minutos, descansa 5. La técnica Pomodoro mejora la concentración.',
    'Dormir 7-8 horas mejora la memoria y el aprendizaje.',
    'Beber agua regularmente mantiene tu cerebro activo y concentrado.',
    'Cada pequeño paso cuenta. No se trata de ser perfecto, sino constante.',
    'La música lofi puede mejorar tu concentración durante el estudio.',
    'Respirar profundo reduce el cortisol y mejora el enfoque.',
    'Hacer pausas activas cada hora previene la fatiga mental.',
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _breathingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));
    _generateNewTip();
  }

  void _generateNewTip() => setState(() => _currentTip = _tips[Random().nextInt(_tips.length)]);

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathingController.repeat(reverse: true);
        _startBreathingCycle();
      } else {
        _breathingController.stop();
        _breathingTimer?.cancel();
      }
    });
  }

  void _startBreathingCycle() {
    _breathingPhase = 0;
    _breathingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) setState(() => _breathingPhase = (_breathingPhase + 1) % 3);
    });
  }

  String _getBreathingText() {
    switch (_breathingPhase) {
      case 0: return 'Inhala...';
      case 1: return 'Mantén...';
      case 2: return 'Exhala...';
      default: return 'Respira...';
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Bienestar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildBreathingCard(),
          const SizedBox(height: 24),
          _buildMoodSelector(),
          const SizedBox(height: 24),
          _buildTipCard(),
          const SizedBox(height: 24),
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildCheckIn(),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: const Row(children: [
        Icon(Icons.self_improvement_rounded, size: 45, color: Colors.white),
        SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cuida tu mente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
          Text('Tu bienestar es tan importante como estudiar', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ])),
      ]),
    );
  }

  Widget _buildBreathingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.air_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Respiración guiada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const Spacer(),
          Switch(value: _isBreathing, onChanged: (_) => _toggleBreathing(), activeThumbColor: AppColors.primary),
        ]),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            return Container(
              width: 150 * _breathingAnimation.value,
              height: 150 * _breathingAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4 * _breathingAnimation.value),
                    blurRadius: 30 * _breathingAnimation.value,
                    spreadRadius: 5 * _breathingAnimation.value,
                  ),
                ],
              ),
              child: const Icon(Icons.pets_rounded, size: 60, color: Colors.white),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(_isBreathing ? _getBreathingText() : 'Activa el interruptor para comenzar', style: TextStyle(fontSize: 16, color: _isBreathing ? AppColors.primary : AppColors.secondaryText, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.mood_rounded, color: AppColors.gold), SizedBox(width: 8), Text('¿Cómo te sientes hoy?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText))]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _moods.asMap().entries.map((entry) {
          final mood = entry.value;
          final index = entry.key;
          final isSelected = _selectedMood == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? mood['color'] as Color : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: isSelected ? Colors.white : mood['color'] as Color, width: 2),
              ),
              child: Column(children: [
                Icon(mood['icon'] as IconData, size: 32, color: isSelected ? Colors.white : mood['color'] as Color),
                const SizedBox(height: 4),
                Text(mood['label'] as String, style: TextStyle(color: isSelected ? Colors.white : AppColors.secondaryText, fontSize: 10)),
              ]),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.2), AppColors.gold.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold),
          const SizedBox(width: 8),
          const Text('Consejo del día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.gold), onPressed: _generateNewTip),
        ]),
        const SizedBox(height: 12),
        Text(_currentTip, style: const TextStyle(color: AppColors.lightText, fontSize: 15, height: 1.6, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.analytics_rounded, color: AppColors.success), SizedBox(width: 8), Text('Tu progreso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText))]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem(Icons.local_fire_department_rounded, '$_wellnessStreak', 'Días', AppColors.tertiary),
          _buildStatItem(Icons.air_rounded, '$_breathingSessions', 'Sesiones', AppColors.primary),
          _buildStatItem(Icons.mood_rounded, _averageMood, 'Promedio', AppColors.success),
        ]),
      ]),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)), child: Icon(icon, color: color, size: 28)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
    ]);
  }

  Widget _buildQuickActions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acciones rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildQuickAction(Icons.music_note_rounded, 'Música Lofi', AppColors.primary),
          _buildQuickAction(Icons.water_drop_rounded, 'Hidratarse', AppColors.cyan),
          _buildQuickAction(Icons.timer_rounded, 'Pomodoro', AppColors.success),
          _buildQuickAction(Icons.bedtime_rounded, 'Recordar sueño', AppColors.histologyPurple),
        ],
      ),
    ]);
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12)), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label - Próximamente'))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.lightText, fontSize: 13), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildCheckIn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.check_circle_outline_rounded, color: AppColors.success), SizedBox(width: 8), Text('Check-in rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText))]),
        const SizedBox(height: 20),
        const Text('¿Cómo está tu energía?', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
        const SizedBox(height: 8),
        Slider(
          value: _energyLevel,
          min: 1, max: 10, divisions: 9,
          label: _energyLevel.round().toString(),
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _energyLevel = v),
        ),
        const SizedBox(height: 16),
        const Text('¿Cuántas horas dormiste?', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (index) {
          final hours = index + 4;
          final isSelected = _sleepHours == hours;
          return GestureDetector(
            onTap: () => setState(() => _sleepHours = hours),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppColors.primary : AppColors.border),
              child: Center(child: Text('$hours', style: TextStyle(color: isSelected ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold))),
            ),
          );
        })),
      ]),
    );
  }
}
