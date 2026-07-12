import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
      body: StreamBuilder(
        stream: firestore.getFlashcards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allCards = snapshot.data ?? [];
          final dueCards = allCards.where((c) => c.isDueForReview).toList();
          final newCards = allCards.where((c) => !c.isLearned).toList();
          final reviewLater = allCards.where((c) => c.isLearned && !c.isDueForReview).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionCard(
                icon: Icons.play_circle_rounded,
                title: 'Pendientes de repaso',
                count: dueCards.length,
                color: AppColors.pharmacologyOrange,
                onTap: dueCards.isNotEmpty
                    ? () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FlashcardPage(flashcards: dueCards, title: 'Repaso Pendiente')))
                    : null,
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                icon: Icons.fiber_new_rounded,
                title: 'Nuevas por aprender',
                count: newCards.length,
                color: AppColors.primary,
                onTap: newCards.isNotEmpty
                    ? () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FlashcardPage(flashcards: newCards, title: 'Nuevas Flashcards')))
                    : null,
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                icon: Icons.check_circle_rounded,
                title: 'Repasadas (próximos días)',
                count: reviewLater.length,
                color: AppColors.success,
                onTap: null,
              ),
              if (dueCards.isEmpty && newCards.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.celebration_rounded, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('¡Todo al día!', style: TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('No hay flashcards pendientes de repaso', style: TextStyle(color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.darkCard,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '$count tarjetas',
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
