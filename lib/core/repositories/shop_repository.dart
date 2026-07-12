import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class ShopRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getShopItems() async {
    final data = await _client.from('shop_items').select().eq('is_active', true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getInventory(String userId) async {
    final data = await _client.from('inventory').select().eq('user_id', userId);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> addToInventory(String userId, String itemId, {int quantity = 1}) async {
    await _client.from('inventory').upsert({
      'user_id': userId,
      'item_id': itemId,
      'quantity': quantity,
    });
  }

  Future<void> addPurchase(String userId, String itemId, int xpSpent) async {
    await _client.from('purchases').insert({
      'user_id': userId,
      'item_id': itemId,
      'xp_spent': xpSpent,
    });
  }

  Future<void> updateInventoryQuantity(String userId, String itemId, int quantity) async {
    await _client.from('inventory').update({
      'quantity': quantity,
    }).eq('user_id', userId).eq('item_id', itemId);
  }

  Future<void> updateXpBoost(String userId, int remainingSessions) async {
    await _client.from('xp_boosts').upsert({
      'user_id': userId,
      'remaining_sessions': remainingSessions,
    });
  }

  Future<Map<String, dynamic>?> getXpBoost(String userId) async {
    return await _client.from('xp_boosts').select().eq('user_id', userId).maybeSingle();
  }

  Future<void> updateCosmetics(String userId, {String? catCosmetic, String? sanctuaryCosmetic}) async {
    final updates = <String, dynamic>{};
    if (catCosmetic != null) updates['active_cat_cosmetic'] = catCosmetic;
    if (sanctuaryCosmetic != null) updates['active_sanctuary_cosmetic'] = sanctuaryCosmetic;
    if (updates.isNotEmpty) {
      await _client.from('cosmetics').upsert({
        'user_id': userId,
        ...updates,
      });
    }
  }

  Future<Map<String, dynamic>?> getCosmetics(String userId) async {
    return await _client.from('cosmetics').select().eq('user_id', userId).maybeSingle();
  }
}
