import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad')),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Card(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.forum_outlined, color: AppColors.info),
                      ),
                      AppSpacing.gapHorizontalMd,
                      Text('Discusiones', style: AppTypography.titleMedium),
                    ],
                  ),
                  AppSpacing.gapVerticalMd,
                  _DiscussionTile(
                    title: '¿Alguien tiene apuntes de cardio?',
                    author: 'Lucía M.',
                    replies: 5,
                    subject: 'Fisiología',
                  ),
                  _DiscussionTile(
                    title: 'Duda sobre vía de las pentosas',
                    author: 'Pedro R.',
                    replies: 3,
                    subject: 'Bioquímica',
                  ),
                  _DiscussionTile(
                    title: 'Tips para anatomía de miembros',
                    author: 'Sofía G.',
                    replies: 8,
                    subject: 'Anatomía',
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapVerticalLg,
          Card(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.help_outline, color: AppColors.success),
                      ),
                      AppSpacing.gapHorizontalMd,
                      Text('Ayuda entre estudiantes', style: AppTypography.titleMedium),
                    ],
                  ),
                  AppSpacing.gapVerticalMd,
                  _HelpChip(label: 'Anatomía', count: 3),
                  _HelpChip(label: 'Fisiología', count: 1),
                  _HelpChip(label: 'Farmacología', count: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionTile extends StatelessWidget {
  final String title;
  final String author;
  final int replies;
  final String subject;
  const _DiscussionTile({required this.title, required this.author, required this.replies, required this.subject});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text('$author • $subject • $replies respuestas',
          style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.secondaryText),
      onTap: () {},
    );
  }
}

class _HelpChip extends StatelessWidget {
  final String label;
  final int count;
  const _HelpChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Chip(
            label: Text(label, style: AppTypography.labelSmall),
            onDeleted: null,
          ),
          AppSpacing.gapHorizontalSm,
          Text('$count solicitudes', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
