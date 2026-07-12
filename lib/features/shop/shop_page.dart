import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text('${user.currentXp}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withValues(alpha: 0.3), AppColors.pharmacologyOrange.withValues(alpha: 0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: AppColors.gold, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gasta tu XP sabiamente', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 15)),
                      const Text('Consigue objetos para potenciar tu estudio', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (shop.hasXpBoost || shop.items.any((i) => i.id == ShopItemId.streakFreeze && i.owned > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (shop.hasXpBoost)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.pharmacologyOrange.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.pharmacologyOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.pharmacologyOrange, size: 16),
                            const SizedBox(width: 4),
                            Text('${shop.activeXpBoostSessions}x XP', style: const TextStyle(color: AppColors.pharmacologyOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    if (shop.items.any((i) => i.id == ShopItemId.streakFreeze && i.owned > 0)) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.ac_unit_rounded, color: AppColors.info, size: 16),
                            const SizedBox(width: 4),
                            Text('Congelador disponible', style: const TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Objetos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: shop.items.length,
              itemBuilder: (context, index) {
                final item = shop.items[index];
                return _buildShopItem(context, item, shop, user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, ShopItem item, ShopProvider shop, UserProvider user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: item.isOwned ? item.color.withValues(alpha: 0.4) : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: () {
            if (item.isOwned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ya tienes ${item.title}'),
                  backgroundColor: AppColors.secondaryText,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            _showPurchaseDialog(context, item, shop, user);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withValues(alpha: 0.15),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const Spacer(),
                    if (item.isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, color: AppColors.success, size: 12),
                            const SizedBox(width: 2),
                            Text('x${item.owned}', style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(item.title, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!item.isOwned) ...[
                      const Icon(Icons.stars_rounded, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text('${item.xpCost}', style: TextStyle(
                        color: user.currentXp >= item.xpCost ? AppColors.gold : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )),
                    ],
                    const Spacer(),
                    Icon(Icons.shopping_cart_rounded, color: item.isOwned ? AppColors.success.withValues(alpha: 0.4) : AppColors.primary, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, ShopItem item, ShopProvider shop, UserProvider user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(20))),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: item.color.withValues(alpha: 0.2)),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item.title, style: const TextStyle(color: AppColors.lightText))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text('${item.xpCost} XP', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Text('Tienes: ${user.currentXp}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              final err = shop.purchase(item.id, user.currentXp);
              if (err.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
                );
              } else {
                user.addXp(-item.xpCost);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡${item.title} adquirido!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.currentXp >= item.xpCost ? AppColors.primary : AppColors.darkCard,
              foregroundColor: Colors.white,
            ),
            child: Text(user.currentXp >= item.xpCost ? 'Comprar' : 'Sin XP'),
          ),
        ],
      ),
    );
  }
}
