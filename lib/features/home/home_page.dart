import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/leloms_cat.dart';
import '../../widgets/section_title.dart';
import '../../providers/profile_provider.dart';
import '../../providers/study_provider.dart';
import '../academic/career_list_page.dart';
import '../resources/library_page.dart';
import '../study/study_timer_page.dart';
import '../study/quiz/quiz_list_page.dart';
import '../ai/ia_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const LibraryPage(),
    const IaPage(),
    const ProfilePageShell(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books), label: 'Biblioteca'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'IA'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final study = context.watch<StudyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.padding(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LelomsCatBanner(
              greeting: '¡Hola, ${profile.userName}!',
              message: _getDailyMessage(),
            ),
            AppSpacing.gapVerticalLg,
            _ContinueStudyingCard(study: study),
            AppSpacing.gapVerticalLg,
            _DailyRecommendation(),
            AppSpacing.gapVerticalLg,
            if (study.nextExam != null) _NextExamCard(exam: study.nextExam!),
            if (study.nextExam != null) AppSpacing.gapVerticalLg,
            SectionTitle(title: 'Recursos recientes', onSeeAll: () {}),
            AppSpacing.gapVerticalMd,
            _RecentResources(),
            AppSpacing.gapVerticalXxl,
            SectionTitle(title: 'Estudiantes destacados', onSeeAll: () {}),
            AppSpacing.gapVerticalMd,
            _TopContributors(),
            AppSpacing.gapVerticalXxl,
          ],
        ),
      ),
    );
  }

  String _getDailyMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Arrancá el día estudiando.';
    if (hour < 18) return 'Seguí con tu ritmo.';
    return 'Aprovechá la noche para repasar.';
  }
}

class _ContinueStudyingCard extends StatelessWidget {
  final StudyProvider study;
  const _ContinueStudyingCard({required this.study});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage())),
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
                child: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
              ),
              AppSpacing.gapHorizontalLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continuar estudiando', style: AppTypography.titleMedium),
                    AppSpacing.gapVerticalXs,
                    Text(
                      'Hoy: ${study.totalMinutesToday} min • sesiones: ${study.sessionsToday}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyRecommendation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.tertiary, size: 20),
                  AppSpacing.gapHorizontalSm,
                  Text('Recomendación del día', style: AppTypography.titleSmall.copyWith(color: AppColors.tertiary)),
                ],
              ),
              AppSpacing.gapVerticalSm,
              Text(
                'Repasá el sistema cardiovascular con flashcards interactivas.',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextExamCard extends StatelessWidget {
  final String exam;
  const _NextExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event, color: AppColors.warning),
            ),
            AppSpacing.gapHorizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Próximo examen', style: AppTypography.titleSmall),
                  Text(exam, style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                  )),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Ver plan')),
          ],
        ),
      ),
    );
  }
}

class _RecentResources extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      {'title': 'Anatomía - Miembros', 'type': 'PDF', 'color': AppColors.anatomyRed},
      {'title': 'Fisiología - Respiratorio', 'type': 'Quiz', 'color': AppColors.physiologyBlue},
      {'title': 'Bioquímica - Enzimas', 'type': 'Flashcard', 'color': AppColors.biochemistryGreen},
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => AppSpacing.gapHorizontalMd,
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item['type'] as String, style: AppTypography.labelSmall.copyWith(color: item['color'] as Color)),
                ),
                const Spacer(),
                Text(item['title'] as String, style: AppTypography.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopContributors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contributors = [
      {'name': 'María G.', 'subject': 'Anatomía', 'helpful': 24},
      {'name': 'Carlos L.', 'subject': 'Fisiología', 'helpful': 18},
      {'name': 'Ana R.', 'subject': 'Bioquímica', 'helpful': 15},
    ];
    return Column(
      children: contributors.map((c) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text((c['name'] as String)[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(c['name'] as String, style: AppTypography.titleSmall),
            subtitle: Text('${c['subject']} • ${c['helpful']} estudiantes ayudados',
                style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
            trailing: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
          ),
        );
      }).toList(),
    );
  }
}

class ProfilePageShell extends StatelessWidget {
  const ProfilePageShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _ProfilePlaceholder(),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil'));
  }
}
