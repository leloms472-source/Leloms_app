import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/quiz.dart';
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
      body: FutureBuilder<List<Quiz>>(
        future: firestore.getQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_rounded, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No hay quizzes disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                  const SizedBox(height: 8),
                  const Text('Los quizzes aparecerán aquí cuando se creen', style: TextStyle(color: AppColors.secondaryText)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    const Text('Todos los quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
                      child: Text('${quizzes.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                );
              }

              final quiz = quizzes[index - 1];
              return _buildQuizCard(context, quiz);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    Color difficultyColor;
    switch (quiz.difficulty) {
      case 'Básico': difficultyColor = AppColors.success; break;
      case 'Avanzado': difficultyColor = AppColors.error; break;
      default: difficultyColor = AppColors.pharmacologyOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(quiz: quiz))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(16)), border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.physiologyBlue.withValues(alpha: 0.15)),
                  child: const Icon(Icons.quiz_rounded, color: AppColors.physiologyBlue, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(quiz.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                  const SizedBox(height: 4),
                  Text(quiz.subject, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: difficultyColor.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Text(quiz.difficulty, style: TextStyle(color: difficultyColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.help_outline_rounded, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text('${quiz.questions.length} preguntas', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.timer_outlined, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text('${quiz.timeMinutes} min', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
