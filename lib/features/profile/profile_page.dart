import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/profile_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/section_title.dart';
import '../auth/login_page.dart';
import '../help/help_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final study = context.watch<StudyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    (profile.userName.isNotEmpty ? profile.userName[0] : '?'),
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                  ),
                ),
                AppSpacing.gapVerticalMd,
                Text(profile.userName, style: AppTypography.titleLarge),
                if (profile.userCareer != null)
                  Text(profile.userCareer!, style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                  )),
              ],
            ),
          ),
          AppSpacing.gapVerticalXxl,
          SectionTitle(title: 'Estadísticas', onSeeAll: null),
          AppSpacing.gapVerticalMd,
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Hoy', value: '${study.totalMinutesToday}m', icon: Icons.today, color: AppColors.primary)),
              AppSpacing.gapHorizontalMd,
              Expanded(child: _StatCard(label: 'Total', value: '${study.allTimeMinutes}m', icon: Icons.timeline, color: AppColors.success)),
            ],
          ),
          AppSpacing.gapVerticalXxl,
          SectionTitle(title: 'Configuración', onSeeAll: null),
          AppSpacing.gapVerticalMd,
          _SettingsTile(icon: Icons.dark_mode, title: 'Modo oscuro', trailing: Switch(value: true, onChanged: (_) {})),
          _SettingsTile(icon: Icons.notifications_outlined, title: 'Notificaciones', trailing: Switch(value: true, onChanged: (_) {})),
          _SettingsTile(icon: Icons.help_outline, title: 'Ayuda entre estudiantes', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()))),
          _SettingsTile(icon: Icons.info_outline, title: 'Acerca de'),
          AppSpacing.gapVerticalXxl,
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            AppSpacing.gapVerticalSm,
            Text(value, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.lightText : AppColors.lightTextPrimary)),
            Text(label, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryText),
        title: Text(title, style: AppTypography.titleSmall),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        onTap: onTap,
      ),
    );
  }
}
