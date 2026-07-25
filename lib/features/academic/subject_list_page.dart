import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/section_title.dart';
import 'topic_detail_page.dart';

class SubjectListPage extends StatelessWidget {
  final String careerName;
  const SubjectListPage({super.key, required this.careerName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjects = [
      {'name': 'Anatomía', 'icon': Icons.biotech, 'color': AppColors.anatomyRed, 'topics': 8},
      {'name': 'Fisiología', 'icon': Icons.monitor_heart_outlined, 'color': AppColors.physiologyBlue, 'topics': 6},
      {'name': 'Bioquímica', 'icon': Icons.science_outlined, 'color': AppColors.biochemistryGreen, 'topics': 7},
      {'name': 'Farmacología', 'icon': Icons.medication_outlined, 'color': AppColors.pharmacologyOrange, 'topics': 5},
      {'name': 'Histología', 'icon': Icons.biotech, 'color': AppColors.histologyPurple, 'topics': 4},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(careerName)),
      body: ListView.separated(
        padding: AppSpacing.paddingLg,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => AppSpacing.gapVerticalSm,
        itemBuilder: (_, i) {
          final s = subjects[i];
          return Card(
            child: ListTile(
              leading: Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: (s['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color),
              ),
              title: Text(s['name'] as String, style: AppTypography.titleSmall),
              subtitle: Text('${s['topics']} temas', style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
              )),
              trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => TopicDetailPage(subjectName: s['name'] as String),
              )),
            ),
          );
        },
      ),
    );
  }
}
