import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/challenge_provider.dart';

class StudyTimerPage extends StatefulWidget {
  const StudyTimerPage({super.key});

  @override
  State<StudyTimerPage> createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionCount = 0;
  String _selectedMode = 'Pomodoro';
  late AnimationController _pulseController;

  final Map<String, int> _modes = {
    'Pomodoro': 25 * 60,
    'Corto': 15 * 60,
    'Profundo': 50 * 60,
    'Descanso': 5 * 60,
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() => _isRunning = true);
    _pulseController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _completeTimer();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _isBreak = false;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _pulseController.reset();
    HapticFeedback.heavyImpact();

    final minutes = _totalSeconds ~/ 60;

    if (!_isBreak) {
      _sessionCount++;
      context.read<ProfileProvider>().addXp(25);
      context.read<StudyProvider>().completeSession(minutes);
      final achievements = context.read<AchievementProvider>();
      achievements.tryUnlock(AchievementId.firstPomodoro);
      if (_sessionCount >= 50) {
        achievements.tryUnlock(AchievementId.focusMaster);
      }
      context.read<ChallengeProvider>().addProgress(ChallengeType.studyTime, minutes);
      context.read<ChallengeProvider>().addProgress(ChallengeType.pomodoroSessions, 1);

      setState(() {
        _isBreak = true;
        _totalSeconds = 5 * 60;
        _remainingSeconds = 5 * 60;
        _isRunning = false;
      });

      _showCompletionDialog('¡Sesión completada!', 'Ganaste 25 XP');
    } else {
      setState(() {
        _isBreak = false;
        _totalSeconds = _modes[_selectedMode] ?? 25 * 60;
        _remainingSeconds = _totalSeconds;
        _isRunning = false;
      });
    }
  }

  void _showCompletionDialog(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.primary],
                ),
              ),
              child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightText,
            )),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(
              color: AppColors.secondaryText, fontSize: 14,
            )),
            const SizedBox(height: 8),
            Text(
              'Sesión $_sessionCount hoy',
              style: const TextStyle(
                color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startTimer();
            },
            child: const Text('Siguiente', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _selectMode(String mode) {
    if (_isRunning) _pauseTimer();
    setState(() {
      _selectedMode = mode;
      _totalSeconds = _modes[mode]!;
      _remainingSeconds = _modes[mode]!;
      _isBreak = false;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress => 1 - (_remainingSeconds / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final userProvider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Temporizador de Estudio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModeSelector(),
            Expanded(child: _buildTimerSection()),
            _buildStatsSection(studyProvider, userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
        children: _modes.keys.map((mode) {
          final isSelected = _selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectMode(mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimerSection() {
    final isActive = _isRunning || _remainingSeconds < _totalSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isRunning
                  ? 1.0 + (_pulseController.value * 0.02)
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 8,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isBreak ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _isBreak ? AppColors.success : AppColors.lightText,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isBreak ? 'Descanso' : 'Estudio',
                            style: TextStyle(
                              color: _isBreak
                                  ? AppColors.success
                                  : AppColors.secondaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive)
                _buildControlButton(
                  icon: Icons.refresh_rounded,
                  color: AppColors.secondaryText,
                  onTap: _resetTimer,
                ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: _isBreak ? AppColors.success : AppColors.primary,
                size: 64,
                iconSize: 36,
                onTap: _isRunning ? _pauseTimer : _startTimer,
              ),
              if (isActive) ...[
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.skip_next_rounded,
                  color: AppColors.secondaryText,
                  onTap: _completeTimer,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (_sessionCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Text(
                '$_sessionCount sesiones completadas',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Widget _buildStatsSection(StudyProvider study, ProfileProvider user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.access_time_rounded, '${study.totalMinutesToday}m', 'Hoy'),
          _buildStatItem(Icons.repeat_rounded, '${study.sessionsToday}', 'Sesiones'),
          _buildStatItem(Icons.local_fire_department_rounded, '${study.currentStreakDays}', 'Racha'),
          _buildStatItem(Icons.auto_graph_rounded, 'Nv. ${user.level}', 'Nivel'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
