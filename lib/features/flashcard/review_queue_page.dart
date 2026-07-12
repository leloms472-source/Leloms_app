import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/flashcard.dart';
import '../../services/firestore_service.dart';
import 'flashcard_page.dart';

class ReviewQueuePage extends StatelessWidget {
  const ReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Repaso Programado'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: firestore.getFlashcards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final allCards = snapshot.data ?? [];
          final dueCards = allCards.where((c) => c.isDueForReview).toList();
          final newCards = allCards.where((c) => !c.isLearned).toList();
          final reviewLater = allCards.where((c) => c.isLearned && !c.isDueForReview).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionCard(Icons.play_circle_rounded, 'Pendientes de repaso', dueCards.length, AppColors.pharmacologyOrange, dueCards.isNotEmpty ? () => _startReview(context, dueCards) : null),
              const SizedBox(height: 12),
              _buildSectionCard(Icons.fiber_new_rounded, 'Nuevas', newCards.length, AppColors.primary, newCards.isNotEmpty ? () => _startReview(context, newCards) : null),
              const SizedBox(height: 12),
              _buildSectionCard(Icons.check_circle_rounded, 'Repasadas', reviewLater.length, AppColors.success, null),
              const SizedBox(height: 24),
              const Text('Cards pendientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              const SizedBox(height: 12),
              ...dueCards.take(5).map((card) => _buildDueCard(context, card)),
              if (dueCards.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(onPressed: () => _startReview(context, dueCards), child: const Text('Ver todas', style: TextStyle(color: AppColors.primary))),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(IconData icon, String title, int count, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(16)), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _buildDueCard(BuildContext context, Flashcard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12)), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(card.isDueForReview ? Icons.schedule_rounded : Icons.check_circle_rounded, color: card.isDueForReview ? AppColors.pharmacologyOrange : AppColors.success, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(card.front, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${card.subject} • ${card.daysUntilReview}d', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardPage(flashcards: [card], title: 'Estudio'))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: const Text('Estudiar', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  void _startReview(BuildContext context, List<Flashcard> cards) {
    if (cards.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardPage(flashcards: cards, title: 'Repaso')));
  }
}
