import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class TopicDetailPage extends StatelessWidget {
  final String subjectName;
  const TopicDetailPage({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = [
      {'name': 'Introducción', 'resources': 4},
      {'name': 'Estructura general', 'resources': 6},
      {'name': 'Sistemas principales', 'resources': 8},
      {'name': 'Relaciones anatómicas', 'resources': 3},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(subjectName)),
      body: ListView.separated(
        padding: AppSpacing.paddingLg,
        itemCount: topics.length,
        separatorBuilder: (_, __) => AppSpacing.gapVerticalSm,
        itemBuilder: (_, i) {
          final t = topics[i];
          return Card(
            child: ListTile(
              leading: Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article_outlined, color: AppColors.primary),
              ),
              title: Text(t['name'] as String, style: AppTypography.titleSmall),
              subtitle: Text('${t['resources']} recursos',
                  style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
