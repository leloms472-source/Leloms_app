import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import 'quiz_page.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: firestore.getQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_rounded,
                      size: 80,
                      color: AppColors.secondaryText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay quizzes disponibles',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conecta Firebase Console para agregar quizzes',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final colors = [
                AppColors.primary,
                AppColors.secondary,
                AppColors.success,
                AppColors.pharmacologyOrange,
                AppColors.info,
              ];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.darkCard,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPage(quiz: quiz),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[index % colors.length]
                                  .withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              color: colors[index % colors.length],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${quiz.subject} • ${quiz.questions.length} preguntas • ${quiz.difficulty}',
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                               borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Text(
                              '${quiz.timeMinutes}min',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
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
