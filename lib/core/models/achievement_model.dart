
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

class AchievementModel {
  final AchievementId id;
  final String title;
  final String description;
  final IconModel icon;
  bool unlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}

class IconModel {
  final int codePoint;
  final String fontFamily;

  const IconModel(this.codePoint, [this.fontFamily = 'MaterialIcons']);
}

class AchievementDefinition {
  static List<AchievementModel> all() {
    return [
      AchievementModel(id: AchievementId.firstQuiz, title: 'Primer Quiz', description: 'Completa tu primer quiz', icon: const IconModel(0xe838)),
      AchievementModel(id: AchievementId.quizMaster, title: 'Maestro Quiz', description: 'Completa 10 quizzes', icon: const IconModel(0xe838)),
      AchievementModel(id: AchievementId.firstFlashcard, title: 'Primera Flashcard', description: 'Completa tu primera sesión de flashcards', icon: const IconModel(0xe8b3)),
      AchievementModel(id: AchievementId.memoryChampion, title: 'Campeón de Memoria', description: 'Aprende 50 flashcards', icon: const IconModel(0xe8b3)),
      AchievementModel(id: AchievementId.firstStreak, title: 'Primera Racha', description: 'Mantén una racha de 3 días', icon: const IconModel(0xe307)),
      AchievementModel(id: AchievementId.weekStreak, title: 'Racha Semanal', description: 'Mantén una racha de 7 días', icon: const IconModel(0xe307)),
      AchievementModel(id: AchievementId.monthStreak, title: 'Racha Mensual', description: 'Mantén una racha de 30 días', icon: const IconModel(0xe307)),
      AchievementModel(id: AchievementId.firstXp, title: 'Primeros Pasos', description: 'Gana 100 XP', icon: const IconModel(0xe8a1)),
      AchievementModel(id: AchievementId.xpCollector, title: 'Coleccionista XP', description: 'Gana 1000 XP', icon: const IconModel(0xe8a1)),
      AchievementModel(id: AchievementId.xpHunter, title: 'Cazador XP', description: 'Gana 5000 XP', icon: const IconModel(0xe8a1)),
      AchievementModel(id: AchievementId.treeGrower, title: 'Jardinero', description: 'Haz crecer tu árbol al nivel Maduro', icon: const IconModel(0xe7f4)),
      AchievementModel(id: AchievementId.ancientTree, title: 'Ancestral', description: 'Haz crecer tu árbol al nivel Ancestral', icon: const IconModel(0xe7f4)),
      AchievementModel(id: AchievementId.socialButterfly, title: 'Mariposa Social', description: 'Comparte tu primer resumen', icon: const IconModel(0xe80d)),
      AchievementModel(id: AchievementId.topContributor, title: 'Top Contribuidor', description: 'Obtén 10 votos en tus resúmenes', icon: const IconModel(0xe80d)),
      AchievementModel(id: AchievementId.firstPomodoro, title: 'Primer Pomodoro', description: 'Completa tu primera sesión de estudio', icon: const IconModel(0xe425)),
      AchievementModel(id: AchievementId.focusMaster, title: 'Maestro del Enfoque', description: 'Completa 50 sesiones de estudio', icon: const IconModel(0xe425)),
    ];
  }
}
