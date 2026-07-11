import 'package:flutter/foundation.dart';

enum CatMood { idle, happy, sleeping, eating, playing }
enum TreeStage { seed, sprout, sapling, young, mature, ancient }

class SanctuaryProvider extends ChangeNotifier {
  int _totalXp = 0;
  int _petCount = 0;
  int _feedCount = 0;
  int _playCount = 0;
  CatMood _catMood = CatMood.idle;
  bool _isTreeWatered = false;

  int get totalXp => _totalXp;
  int get petCount => _petCount;
  int get feedCount => _feedCount;
  int get playCount => _playCount;
  CatMood get catMood => _catMood;
  bool get isTreeWatered => _isTreeWatered;

  TreeStage get treeStage {
    if (_totalXp >= 2000) return TreeStage.ancient;
    if (_totalXp >= 1000) return TreeStage.mature;
    if (_totalXp >= 600) return TreeStage.young;
    if (_totalXp >= 300) return TreeStage.sapling;
    if (_totalXp >= 100) return TreeStage.sprout;
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
    final stages = [0, 100, 300, 600, 1000, 2000];
    final currentIndex = treeStage.index;
    if (currentIndex >= stages.length - 1) return 1.0;
    final currentMin = stages[currentIndex];
    final nextMin = stages[currentIndex + 1];
    return (_totalXp - currentMin) / (nextMin - currentMin);
  }

  void addXp(int amount) {
    _totalXp += amount;
    notifyListeners();
  }

  void petCat() {
    _petCount++;
    _catMood = CatMood.happy;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _catMood = CatMood.idle;
      notifyListeners();
    });
  }

  void feedCat() {
    _feedCount++;
    _catMood = CatMood.eating;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _catMood = CatMood.idle;
      notifyListeners();
    });
  }

  void playWithCat() {
    _playCount++;
    _catMood = CatMood.playing;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _catMood = CatMood.idle;
      notifyListeners();
    });
  }

  void waterTree() {
    _isTreeWatered = true;
    notifyListeners();
  }

  void addStudyXp(int minutes) {
    addXp(minutes * 5);
  }
}
