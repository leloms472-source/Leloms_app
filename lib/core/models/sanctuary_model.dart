enum CatMood { idle, happy, sleeping, eating, playing }
enum TreeStage { seed, sprout, sapling, young, mature, ancient }

class SanctuaryModel {
  final String id;
  final String userId;
  int totalXp;
  bool isTreeWatered;

  SanctuaryModel({
    required this.id,
    required this.userId,
    this.totalXp = 0,
    this.isTreeWatered = false,
  });

  TreeStage get treeStage {
    if (totalXp >= 2000) return TreeStage.ancient;
    if (totalXp >= 1000) return TreeStage.mature;
    if (totalXp >= 600) return TreeStage.young;
    if (totalXp >= 300) return TreeStage.sapling;
    if (totalXp >= 100) return TreeStage.sprout;
    return TreeStage.seed;
  }

  String get treeStageName {
    switch (treeStage) {
      case TreeStage.seed: return 'Semilla';
      case TreeStage.sprout: return 'Brote';
      case TreeStage.sapling: return 'Árbol Joven';
      case TreeStage.young: return 'Árbol en Crecimiento';
      case TreeStage.mature: return 'Árbol Maduro';
      case TreeStage.ancient: return 'Árbol Ancestral';
    }
  }

  double get treeProgress {
    const stages = [0, 100, 300, 600, 1000, 2000];
    final currentIndex = treeStage.index;
    if (currentIndex >= stages.length - 1) return 1.0;
    final currentMin = stages[currentIndex];
    final nextMin = stages[currentIndex + 1];
    return (totalXp - currentMin) / (nextMin - currentMin);
  }

  factory SanctuaryModel.fromMap(Map<String, dynamic> map) {
    return SanctuaryModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      totalXp: (map['total_xp'] as num?)?.toInt() ?? 0,
      isTreeWatered: map['is_tree_watered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'total_xp': totalXp,
        'is_tree_watered': isTreeWatered,
      };
}

class PetModel {
  final String id;
  final String userId;
  String name;
  String petType;
  String mood;
  int petCount;
  int feedCount;
  int playCount;

  PetModel({
    required this.id,
    required this.userId,
    this.name = 'Gato',
    this.petType = 'cat',
    this.mood = 'idle',
    this.petCount = 0,
    this.feedCount = 0,
    this.playCount = 0,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? 'Gato',
      petType: map['pet_type'] as String? ?? 'cat',
      mood: map['mood'] as String? ?? 'idle',
      petCount: (map['pet_count'] as num?)?.toInt() ?? 0,
      feedCount: (map['feed_count'] as num?)?.toInt() ?? 0,
      playCount: (map['play_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'mood': mood,
        'pet_count': petCount,
        'feed_count': feedCount,
        'play_count': playCount,
      };
}
