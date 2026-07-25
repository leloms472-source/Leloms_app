import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quizzes = [
      {'title': 'Anatomía - Sistema Cardíaco', 'questions': 10, 'color': AppColors.anatomyRed},
      {'title': 'Fisiología - Respiratorio', 'questions': 8, 'color': AppColors.physiologyBlue},
      {'title': 'Bioquímica - Enzimas', 'questions': 12, 'color': AppColors.biochemistryGreen},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: ListView.separated(
        padding: AppSpacing.paddingLg,
        itemCount: quizzes.length,
        separatorBuilder: (_, __) => AppSpacing.gapVerticalSm,
        itemBuilder: (_, i) {
          final q = quizzes[i];
          return Card(
            child: ListTile(
              leading: Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: (q['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.quiz_outlined, color: q['color'] as Color),
              ),
              title: Text(q['title'] as String, style: AppTypography.titleSmall),
              subtitle: Text('${q['questions']} preguntas',
                  style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
              trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
