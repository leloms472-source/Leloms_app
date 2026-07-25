import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/section_title.dart';
import 'subject_list_page.dart';

class CareerListPage extends StatelessWidget {
  const CareerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.padding(context);

    final careers = [
      {'name': 'Medicina', 'icon': Icons.medical_services_outlined, 'color': AppColors.primary, 'subjects': 12},
      {'name': 'Enfermería', 'icon': Icons.local_hospital_outlined, 'color': AppColors.secondary, 'subjects': 8},
      {'name': 'Bioquímica', 'icon': Icons.biotech_outlined, 'color': AppColors.biochemistryGreen, 'subjects': 6},
      {'name': 'Odontología', 'icon': Icons.face_outlined, 'color': AppColors.tertiary, 'subjects': 10},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Carreras')),
      body: GridView.builder(
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.gridColumns(context),
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
          childAspectRatio: 1.1,
        ),
        itemCount: careers.length,
        itemBuilder: (_, i) {
          final c = careers[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SubjectListPage(careerName: c['name'] as String),
              )),
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: (c['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 32),
                    ),
                    AppSpacing.gapVerticalMd,
                    Text(c['name'] as String, style: AppTypography.titleSmall, textAlign: TextAlign.center),
                    Text('${c['subjects']} materias', style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
