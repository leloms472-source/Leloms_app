import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShopItemId {
  streakFreeze,
  xpBoost,
  treeBoost,
  catHat,
  catBowtie,
  starBackground,
  goldenTree,
}

class ShopItem {
  final ShopItemId id;
  final String title;
  final String description;
  final int xpCost;
  final IconData icon;
  final Color color;
  int owned;

  ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.xpCost,
    required this.icon,
    required this.color,
    this.owned = 0,
  });

  bool get isOwned => owned > 0;
}

class ShopProvider extends ChangeNotifier {
  final List<ShopItem> _items = _allItems();
  int _activeXpBoostSessions = 0;
  int _streakFreezesUsed = 0;
  String? _activeCatCosmetic;
  String? _activeSanctuaryCosmetic;

  List<ShopItem> get items => List.unmodifiable(_items);
  int get activeXpBoostSessions => _activeXpBoostSessions;
  int get streakFreezesUsed => _streakFreezesUsed;
  bool get hasXpBoost => _activeXpBoostSessions > 0;
  String? get activeCatCosmetic => _activeCatCosmetic;
  String? get activeSanctuaryCosmetic => _activeSanctuaryCosmetic;

  static const _keyInventory = 'shop_inventory';
  static const _keyBoostSessions = 'shop_xp_boost';
  static const _keyFreezesUsed = 'shop_freezes';
  static const _keyCatCosmetic = 'shop_cat_cosmetic';
  static const _keySanctuaryCosmetic = 'shop_sanctuary_cosmetic';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final inv = prefs.getStringList(_keyInventory) ?? [];
    for (final entry in inv) {
      final parts = entry.split(':');
      final id = ShopItemId.values.firstWhere(
        (e) => e.name == parts[0],
        orElse: () => ShopItemId.streakFreeze,
      );
      final item = _items.firstWhere((i) => i.id == id);
      item.owned = int.tryParse(parts[1]) ?? 1;
    }
    _activeXpBoostSessions = prefs.getInt(_keyBoostSessions) ?? 0;
    _streakFreezesUsed = prefs.getInt(_keyFreezesUsed) ?? 0;
    _activeCatCosmetic = prefs.getString(_keyCatCosmetic);
    _activeSanctuaryCosmetic = prefs.getString(_keySanctuaryCosmetic);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyInventory,
      _items.where((i) => i.owned > 0).map((i) => '${i.id.name}:${i.owned}').toList(),
    );
    await prefs.setInt(_keyBoostSessions, _activeXpBoostSessions);
    await prefs.setInt(_keyFreezesUsed, _streakFreezesUsed);
    if (_activeCatCosmetic != null) await prefs.setString(_keyCatCosmetic, _activeCatCosmetic!);
    if (_activeSanctuaryCosmetic != null) await prefs.setString(_keySanctuaryCosmetic, _activeSanctuaryCosmetic!);
  }

  bool canAfford(int xpCost, int currentXp) => currentXp >= xpCost;

  String purchase(ShopItemId id, int currentXp) {
    final item = _items.firstWhere((i) => i.id == id);
    if (!canAfford(item.xpCost, currentXp)) return 'XP insuficiente';
    item.owned++;
    notifyListeners();
    _save();
    return '';
  }

  bool useStreakFreeze() {
    final item = _items.firstWhere((i) => i.id == ShopItemId.streakFreeze);
    if (item.owned <= 0) return false;
    item.owned--;
    _streakFreezesUsed++;
    notifyListeners();
    _save();
    return true;
  }

  bool activateXpBoost() {
    final item = _items.firstWhere((i) => i.id == ShopItemId.xpBoost);
    if (item.owned <= 0) return false;
    item.owned--;
    _activeXpBoostSessions += 3;
    notifyListeners();
    _save();
    return true;
  }

  void consumeXpBoostSession() {
    if (_activeXpBoostSessions > 0) {
      _activeXpBoostSessions--;
      notifyListeners();
      _save();
    }
  }

  bool applyTreeBoost() {
    final item = _items.firstWhere((i) => i.id == ShopItemId.treeBoost);
    if (item.owned <= 0) return false;
    item.owned--;
    notifyListeners();
    _save();
    return true;
  }

  void equipCatCosmetic(String cosmeticId) {
    _activeCatCosmetic = cosmeticId;
    notifyListeners();
    _save();
  }

  void equipSanctuaryCosmetic(String cosmeticId) {
    _activeSanctuaryCosmetic = cosmeticId;
    notifyListeners();
    _save();
  }

  static List<ShopItem> _allItems() {
    return [
      ShopItem(
        id: ShopItemId.streakFreeze,
        title: 'Congelar Racha',
        description: 'Preserva tu racha si olvidas estudiar un día',
        xpCost: 200,
        icon: Icons.ac_unit_rounded,
        color: const Color(0xFF06B6D4),
      ),
      ShopItem(
        id: ShopItemId.xpBoost,
        title: 'Impulso XP',
        description: 'Gana el doble de XP en tus próximas 3 sesiones',
        xpCost: 100,
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF59E0B),
      ),
      ShopItem(
        id: ShopItemId.treeBoost,
        title: 'Abono Mágico',
        description: 'Acelera el crecimiento de tu árbol',
        xpCost: 150,
        icon: Icons.eco_rounded,
        color: const Color(0xFF10B981),
      ),
      ShopItem(
        id: ShopItemId.catHat,
        title: 'Sombrero Elegante',
        description: 'Un sombrero diminuto para tu gato',
        xpCost: 300,
        icon: Icons.face_5_rounded,
        color: const Color(0xFFEC4899),
      ),
      ShopItem(
        id: ShopItemId.catBowtie,
        title: 'Corbatín Rojo',
        description: 'Un elegante corbatín para tu mascota',
        xpCost: 250,
        icon: Icons.circle_rounded,
        color: const Color(0xFFEF4444),
      ),
      ShopItem(
        id: ShopItemId.starBackground,
        title: 'Fondo Estelar',
        description: 'Estrellas brillantes en el santuario',
        xpCost: 500,
        icon: Icons.nights_stay_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      ShopItem(
        id: ShopItemId.goldenTree,
        title: 'Árbol Dorado',
        description: 'Transforma tu árbol en oro brillante',
        xpCost: 800,
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFD4AF37),
      ),
    ];
  }
}
