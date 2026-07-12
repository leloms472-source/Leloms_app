import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/supabase/supabase_client.dart';

enum ChallengeType { studyTime, flashcards, quizQuestions, streak, pomodoroSessions }

class DailyChallenge {
  final ChallengeType type;
  final int target;
  final String title;
  final String description;
  final int xpReward;
  int progress;

  DailyChallenge({
    required this.type,
    required this.target,
    required this.title,
    required this.description,
    required this.xpReward,
    this.progress = 0,
  });

  bool get isCompleted => progress >= target;
  double get progressFraction => (progress / target).clamp(0.0, 1.0);
}

class ChallengeProvider extends ChangeNotifier {
  List<DailyChallenge> _challenges = [];
  DateTime _lastGenerated = DateTime(2000);
  int _completedRewardsClaimed = 0;
  String? _userId;

  List<DailyChallenge> get challenges => List.unmodifiable(_challenges);
  int get completedCount => _challenges.where((c) => c.isCompleted).length;
  int get totalCount => _challenges.length;
  bool get allCompleted => _challenges.isNotEmpty && _challenges.every((c) => c.isCompleted);

  static const _keyDate = 'challenge_last_date';
  static const _keyTypes = 'challenge_types';
  static const _keyTargets = 'challenge_targets';
  static const _keyProgress = 'challenge_progress';
  static const _keyClaimed = 'challenge_claimed';

  Future<void> loadFromServer(String userId) async {
    _userId = userId;
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final data = await SupabaseConfig.client.from('challenges')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .order('created_at');
      if ((data as List).isNotEmpty) {
        _challenges = (data as List).map((d) => DailyChallenge(
          type: ChallengeType.values.firstWhere((e) => e.name == d['challenge_type']),
          target: (d['target'] as num).toInt(),
          title: d['title'] as String,
          description: d['description'] as String,
          xpReward: (d['xp_reward'] as num).toInt(),
          progress: (d['progress'] as num).toInt(),
        )).toList();
        _completedRewardsClaimed = _challenges.where((c) => c.isCompleted).length;
        notifyListeners();
        return;
      }
    } catch (_) {}
    await initialize();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyDate);
    if (savedDate != null) {
      _lastGenerated = DateTime.parse(savedDate);
    }
    _completedRewardsClaimed = prefs.getInt(_keyClaimed) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastGenerated.year, _lastGenerated.month, _lastGenerated.day);

    if (lastDay == today && savedDate != null) {
      _loadSaved(prefs);
    } else {
      _generateNew(prefs);
    }
  }

  void _loadSaved(SharedPreferences prefs) {
    final types = prefs.getStringList(_keyTypes) ?? [];
    final targets = prefs.getStringList(_keyTargets) ?? [];
    final progress = prefs.getStringList(_keyProgress) ?? [];

    _challenges = [];
    for (int i = 0; i < types.length && i < targets.length && i < progress.length; i++) {
      _challenges.add(DailyChallenge(
        type: ChallengeType.values[int.parse(types[i])],
        target: int.parse(targets[i]),
        title: _titleForType(ChallengeType.values[int.parse(types[i])]),
        description: _descForType(ChallengeType.values[int.parse(types[i])], int.parse(targets[i])),
        xpReward: int.parse(targets[i]) * 5,
        progress: int.parse(progress[i]),
      ));
    }
  }

  void _generateNew(SharedPreferences prefs) {
    final rng = Random();
    final types = [ChallengeType.studyTime, ChallengeType.flashcards, ChallengeType.quizQuestions];
    final shuffled = types.toList()..shuffle(rng);
    final selected = shuffled.take(3).toList();
    final targets = selected.map((t) {
      switch (t) {
        case ChallengeType.studyTime: return 20 + rng.nextInt(3) * 10;
        case ChallengeType.flashcards: return 5 + rng.nextInt(3) * 5;
        case ChallengeType.quizQuestions: return 3 + rng.nextInt(3) * 3;
        case ChallengeType.streak: return 3;
        case ChallengeType.pomodoroSessions: return 2 + rng.nextInt(2);
      }
    }).toList();

    _challenges = List.generate(3, (i) => DailyChallenge(
      type: selected[i],
      target: targets[i],
      title: _titleForType(selected[i]),
      description: _descForType(selected[i], targets[i]),
      xpReward: targets[i] * 5,
    ));

    _save(prefs);
  }

  String _titleForType(ChallengeType type) {
    switch (type) {
      case ChallengeType.studyTime: return 'Tiempo de Estudio';
      case ChallengeType.flashcards: return 'Flashcards';
      case ChallengeType.quizQuestions: return 'Preguntas Quiz';
      case ChallengeType.streak: return 'Racha';
      case ChallengeType.pomodoroSessions: return 'Pomodoros';
    }
  }

  String _descForType(ChallengeType type, int target) {
    switch (type) {
      case ChallengeType.studyTime: return 'Estudia $target minutos';
      case ChallengeType.flashcards: return 'Revisa $target flashcards';
      case ChallengeType.quizQuestions: return 'Responde $target preguntas';
      case ChallengeType.streak: return 'Mantén $target días de racha';
      case ChallengeType.pomodoroSessions: return 'Completa $target sesiones';
    }
  }

  void _save(SharedPreferences prefs) async {
    final now = DateTime.now();
    _lastGenerated = now;
    await prefs.setString(_keyDate, now.toIso8601String());
    await prefs.setStringList(_keyTypes, _challenges.map((c) => c.type.index.toString()).toList());
    await prefs.setStringList(_keyTargets, _challenges.map((c) => c.target.toString()).toList());
    await prefs.setStringList(_keyProgress, _challenges.map((c) => c.progress.toString()).toList());
    await prefs.setInt(_keyClaimed, _completedRewardsClaimed);

    if (_userId != null) {
      for (final c in _challenges) {
        try {
          await SupabaseConfig.client.from('challenges').upsert({
            'user_id': _userId!,
            'challenge_type': c.type.name,
            'target': c.target,
            'title': c.title,
            'description': c.description,
            'xp_reward': c.xpReward,
            'progress': c.progress,
            'is_completed': c.isCompleted,
            'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          });
        } catch (_) {}
      }
    }
  }

  void addProgress(ChallengeType type, int amount) {
    bool changed = false;
    for (final c in _challenges) {
      if (c.type == type && !c.isCompleted) {
        c.progress = (c.progress + amount).clamp(0, c.target);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      SharedPreferences.getInstance().then((prefs) => _save(prefs));
    }
  }

  int claimAllRewards() {
    if (!allCompleted || _completedRewardsClaimed >= _challenges.length) return 0;
    final total = _challenges.fold(0, (sum, c) => sum + c.xpReward);
    _completedRewardsClaimed = _challenges.length;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => _save(prefs));
    return total;
  }

  bool get canClaim => allCompleted && _completedRewardsClaimed < _challenges.length;
}
