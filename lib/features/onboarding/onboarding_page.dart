import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.school_rounded,
      title: 'Bienvenido a LELOMS',
      description: 'Tu asistente de estudio inteligente para estudiantes de medicina. Aprende más rápido y retén mejor.',
      color: AppColors.primary,
    ),
    _OnboardingStep(
      icon: Icons.smart_toy_rounded,
      title: 'IA Leloms',
      description: 'Chat con IA especializada en ciencias médicas. Crea quizzes, flashcards y resúmenes al instante.',
      color: AppColors.secondary,
    ),
    _OnboardingStep(
      icon: Icons.auto_graph_rounded,
      title: 'Tu Progreso',
      description: 'Gana XP, sube de nivel, mantén rachas y desbloquea logros mientras estudias.',
      color: AppColors.success,
    ),
    _OnboardingStep(
      icon: Icons.pets_rounded,
      title: 'Santuario Personal',
      description: 'Cuida de Leloms y haz crecer tu árbol mágico cuanto más estudias.',
      color: AppColors.pharmacologyOrange,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text('Saltar', style: TextStyle(color: AppColors.secondaryText)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) => _buildStep(_steps[index]),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(_OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [step.color, step.color.withValues(alpha: 0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: step.color.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)],
            ),
            child: Icon(step.icon, size: 72, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(step.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightText), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(step.description, style: const TextStyle(color: AppColors.secondaryText, fontSize: 16, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(_steps.length, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == i ? AppColors.primary : AppColors.border,
              ),
            )),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _steps.length - 1) {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  _complete();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(_currentPage < _steps.length - 1 ? 'Siguiente' : 'Comenzar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
