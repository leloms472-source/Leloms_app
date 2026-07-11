import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import 'flashcard_page.dart';
import 'review_queue_page.dart';

class FlashcardListPage extends StatelessWidget {
  const FlashcardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewQueuePage())),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.getFlashcards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final flashcards = snapshot.data ?? [];

          if (flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_rounded,
                      size: 80,
                      color: AppColors.secondaryText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay flashcards disponibles',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conecta Firebase Console para agregar flashcards',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final card = flashcards[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Group flashcards by subject and start session
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardPage(
                            flashcards: [card],
                            title: card.subject,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.pharmacologyOrange
                                  .withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.credit_card_rounded,
                              color: AppColors.pharmacologyOrange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.front,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.subject,
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (card.isLearned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✅',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.secondaryText),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
