import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/flashcard.dart';
import '../../services/supabase_service.dart';
import 'flashcard_page.dart';
import 'review_queue_page.dart';

class FlashcardListPage extends StatelessWidget {
  final String? subject;
  const FlashcardListPage({super.key, this.subject});

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(subject != null ? 'Flashcards - $subject' : 'Flashcards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewQueuePage())),
          ),
        ],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: supabase.getFlashcards(subject: subject),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final flashcards = snapshot.data ?? [];

          if (flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_rounded, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No hay flashcards', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                  const SizedBox(height: 8),
                  const Text('Crea flashcards para estudiar', style: TextStyle(color: AppColors.secondaryText)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flashcards.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    const Text('Todas las flashcards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
                      child: Text('${flashcards.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                );
              }

              final card = flashcards[index - 1];
              return _buildCardItem(context, card);
            },
          );
        },
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, dynamic card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardPage(flashcards: [card], title: 'Flashcard'))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12)), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: card.isDueForReview ? AppColors.pharmacologyOrange.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15)),
                child: Icon(card.isDueForReview ? Icons.schedule_rounded : Icons.check_circle_rounded, color: card.isDueForReview ? AppColors.pharmacologyOrange : AppColors.success, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.front, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(card.subject, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ])),
              Icon(card.isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: card.isLearned ? AppColors.success : AppColors.secondaryText, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}
