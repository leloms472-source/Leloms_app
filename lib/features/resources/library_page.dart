import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/enums/enums.dart';
import '../../widgets/section_title.dart';
import '../academic/career_list_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerListPage())),
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Row(
                      children: [
                        Container(
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.school, color: AppColors.primary, size: 32),
                        ),
                        AppSpacing.gapHorizontalLg,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Explorar por carrera', style: AppTypography.titleMedium),
                              Text('Materias, temas y recursos organizados',
                                  style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.gapVerticalXxl,
            SectionTitle(title: 'Recursos públicos', onSeeAll: () {}),
            AppSpacing.gapVerticalMd,
            _ResourceSection(title: 'Resúmenes', icon: Icons.summarize_outlined, color: AppColors.info),
            AppSpacing.gapVerticalSm,
            _ResourceSection(title: 'Flashcards', icon: Icons.style_outlined, color: AppColors.secondary),
            AppSpacing.gapVerticalSm,
            _ResourceSection(title: 'Quizzes', icon: Icons.quiz_outlined, color: AppColors.tertiary),
            AppSpacing.gapVerticalSm,
            _ResourceSection(title: 'Exámenes', icon: Icons.assignment_outlined, color: AppColors.pharmacologyOrange),
            AppSpacing.gapVerticalXxl,
            SectionTitle(title: 'Mis recursos', onSeeAll: () {}),
            AppSpacing.gapVerticalMd,
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _UploadCard(),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Padding(
                          padding: AppSpacing.paddingMd,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_outlined, color: AppColors.secondaryText),
                              AppSpacing.gapVerticalXs,
                              Text('Privados', style: AppTypography.labelSmall, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _ResourceSection({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: ListTile(
        leading: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTypography.titleSmall),
        trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        onTap: () {},
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, color: AppColors.primary),
              AppSpacing.gapVerticalXs,
              Text('Subir PDF', style: AppTypography.labelSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
