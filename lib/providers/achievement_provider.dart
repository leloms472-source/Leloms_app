import 'package:flutter/foundation.dart';
import '../core/repositories/achievement_repository.dart';

enum AchievementId {
  firstQuiz,
  quizMaster,
  firstFlashcard,
  memoryChampion,
  firstStreak,
  weekStreak,
  monthStreak,
  firstXp,
  xpCollector,
  xpHunter,
  treeGrower,
  ancientTree,
  socialButterfly,
  topContributor,
  firstPomodoro,
  focusMaster,
}

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final IconInfo icon;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}

class IconInfo {
  final int codePoint;
  final String fontFamily;

  const IconInfo(this.codePoint, [this.fontFamily = 'MaterialIcons']);
}

class AchievementProvider extends ChangeNotifier {
  late final AchievementRepository _repo;
  final List<Achievement> _achievements = _allAchievements();
  Achievement? _lastUnlocked;
  String? _userId;

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get unlocked => _achievements.where((a) => a.unlocked).toList();
  List<Achievement> get locked => _achievements.where((a) => !a.unlocked).toList();
  int get unlockedCount => unlocked.length;
  int get totalCount => _achievements.length;
  double get progress => unlockedCount / totalCount;
  Achievement? get lastUnlocked => _lastUnlocked;

  AchievementProvider() {
    _repo = AchievementRepository();
  }

  bool isUnlocked(AchievementId id) =>
      _achievements.firstWhere((a) => a.id == id).unlocked;

  Future<void> loadFromServer(String userId) async {
    _userId = userId;
    try {
      final unlockedAchievements = await _repo.getUserAchievements(userId);
      final unlockedIds = unlockedAchievements.map((a) => a['achievement_id'] as String).toSet();
      for (final achievement in _achievements) {
        if (unlockedIds.contains(achievement.id.name)) {
          achievement.unlocked = true;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  bool tryUnlock(AchievementId id) {
    final achievement = _achievements.firstWhere((a) => a.id == id);
    if (achievement.unlocked) return false;
    achievement.unlocked = true;
    _lastUnlocked = achievement;
    notifyListeners();

    if (_userId != null) {
      _repo.unlockAchievement(
        _userId!,
        achievement.id.name,
        achievement.title,
        achievement.description,
      );
    }

    return true;
  }

  static List<Achievement> _allAchievements() {
    return [
      Achievement(id: AchievementId.firstQuiz, title: 'Primer Quiz', description: 'Completa tu primer quiz', icon: const IconInfo(0xe838)),
      Achievement(id: AchievementId.quizMaster, title: 'Maestro Quiz', description: 'Completa 10 quizzes', icon: const IconInfo(0xe838)),
      Achievement(id: AchievementId.firstFlashcard, title: 'Primera Flashcard', description: 'Completa tu primera sesión de flashcards', icon: const IconInfo(0xe8b3)),
      Achievement(id: AchievementId.memoryChampion, title: 'Campeón de Memoria', description: 'Aprende 50 flashcards', icon: const IconInfo(0xe8b3)),
      Achievement(id: AchievementId.firstStreak, title: 'Primera Racha', description: 'Mantén una racha de 3 días', icon: const IconInfo(0xe307)),
      Achievement(id: AchievementId.weekStreak, title: 'Racha Semanal', description: 'Mantén una racha de 7 días', icon: const IconInfo(0xe307)),
      Achievement(id: AchievementId.monthStreak, title: 'Racha Mensual', description: 'Mantén una racha de 30 días', icon: const IconInfo(0xe307)),
      Achievement(id: AchievementId.firstXp, title: 'Primeros Pasos', description: 'Gana 100 XP', icon: const IconInfo(0xe8a1)),
      Achievement(id: AchievementId.xpCollector, title: 'Coleccionista XP', description: 'Gana 1000 XP', icon: const IconInfo(0xe8a1)),
      Achievement(id: AchievementId.xpHunter, title: 'Cazador XP', description: 'Gana 5000 XP', icon: const IconInfo(0xe8a1)),
      Achievement(id: AchievementId.treeGrower, title: 'Jardinero', description: 'Haz crecer tu árbol al nivel Maduro', icon: const IconInfo(0xe7f4)),
      Achievement(id: AchievementId.ancientTree, title: 'Ancestral', description: 'Haz crecer tu árbol al nivel Ancestral', icon: const IconInfo(0xe7f4)),
      Achievement(id: AchievementId.socialButterfly, title: 'Mariposa Social', description: 'Comparte tu primer resumen', icon: const IconInfo(0xe80d)),
      Achievement(id: AchievementId.topContributor, title: 'Top Contribuidor', description: 'Obtén 10 votos en tus resúmenes', icon: const IconInfo(0xe80d)),
      Achievement(id: AchievementId.firstPomodoro, title: 'Primer Pomodoro', description: 'Completa tu primera sesión de estudio', icon: const IconInfo(0xe425)),
      Achievement(id: AchievementId.focusMaster, title: 'Maestro del Enfoque', description: 'Completa 50 sesiones de estudio', icon: const IconInfo(0xe425)),
    ];
  }
}
