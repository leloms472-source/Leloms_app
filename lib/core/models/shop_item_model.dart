import 'package:flutter/material.dart';

enum ShopItemId {
  streakFreeze,
  xpBoost,
  treeBoost,
  catHat,
  catBowtie,
  starBackground,
  goldenTree,
}

class ShopItemModel {
  final ShopItemId id;
  final String title;
  final String description;
  final int xpCost;
  final IconData icon;
  final Color color;
  int owned;

  ShopItemModel({
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
