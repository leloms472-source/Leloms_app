import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../ia/ia_page.dart';
import '../ia/community_page.dart';
import '../library/library_page.dart';
import '../wellness/wellness_page.dart';
import '../calendar/calendar_page.dart';
import '../profile/profile_page.dart';
import '../sanctuary/sanctuary_page.dart';
import '../study/study_timer_page.dart';
import '../analytics/analytics_page.dart';
import '../exam/exam_config_page.dart';
import '../search/global_search_page.dart';
import '../study_plan/study_plan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final study = context.watch<StudyProvider>();
    final sanctuary = context.watch<SanctuaryProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      drawer: _buildDrawer(user),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.lightText),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 20),
            _buildLiveStats(user, sanctuary),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildDueReviews(),
            const SizedBox(height: 24),
            _buildTodayStudy(study),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(UserProvider user) {
    return Drawer(
      backgroundColor: AppColors.dark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, size: 35, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(user.userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Nivel ${user.level} • ${user.currentXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.checklist_rounded, 'Plan de Estudio', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanPage()))),
          _buildDrawerItem(Icons.assignment_rounded, 'Simulacros', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
          _buildDrawerItem(Icons.show_chart_rounded, 'Progreso', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage()))),
          _buildDrawerItem(Icons.timer_rounded, 'Temporizador', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage()))),
          _buildDrawerItem(Icons.pets_rounded, 'Santuario', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SanctuaryPage()))),
          _buildDrawerItem(Icons.school_rounded, 'Biblioteca', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryPage()))),
          _buildDrawerItem(Icons.self_improvement_rounded, 'Bienestar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessPage()))),
          _buildDrawerItem(Icons.calendar_month_rounded, 'Calendario', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()))),
          _buildDrawerItem(Icons.person_rounded, 'Perfil', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
          const Divider(color: AppColors.border),
          _buildDrawerItem(Icons.settings_rounded, 'Configuración', () {}),
          _buildDrawerItem(Icons.logout_rounded, 'Cerrar sesión', () {}, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.secondaryText),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.lightText)),
      onTap: onTap,
    );
  }

  Widget _buildHeader(UserProvider user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'Buenos días';
    else if (hour < 18) greeting = 'Buenas tardes';
    else greeting = 'Buenas noches';

    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
          ),
          child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, ${user.userName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              Text(_formattedDate, style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  String get _formattedDate {
    final now = DateTime.now();
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  Widget _buildLiveStats(UserProvider user, SanctuaryProvider sanctuary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text('Racha: ${user.streak} días', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.pets_rounded, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text('Árbol: ${sanctuary.treeStageName}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Nv. ${user.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  Text('${user.currentXp} / ${user.nextLevelXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: user.xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acceso Rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQuickCard(Icons.smart_toy_rounded, 'IA Leloms', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IaPage())))),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickCard(Icons.assignment_rounded, 'Simulacro', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage())))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildQuickCard(Icons.timer_rounded, 'Pomodoro', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage())))),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickCard(Icons.groups_rounded, 'Comunidad', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage())))),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDueReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('flashcards').snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs ?? [];
        final now = DateTime.now();
        int dueCount = 0;
        int newCount = 0;

        for (final doc in data) {
          final card = doc.data() as Map<String, dynamic>;
          final isLearned = card['isLearned'] as bool? ?? false;
          if (!isLearned) {
            newCount++;
            continue;
          }
          final nextReview = card['nextReviewDate'] as String?;
          if (nextReview != null) {
            final reviewDate = DateTime.parse(nextReview);
            if (now.isAfter(reviewDate)) dueCount++;
          }
        }

        final total = dueCount + newCount;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: total > 0 ? AppColors.pharmacologyOrange.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: total > 0 ? AppColors.pharmacologyOrange.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15),
                ),
                child: Icon(
                  total > 0 ? Icons.schedule_rounded : Icons.check_circle_rounded,
                  color: total > 0 ? AppColors.pharmacologyOrange : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      total > 0 ? 'Repaso pendiente' : 'Todo al día',
                      style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      total > 0
                          ? '$total flashcards por repasar ($dueCount vencidas, $newCount nuevas)'
                          : 'No hay flashcards pendientes',
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pharmacologyOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$total', style: const TextStyle(color: AppColors.pharmacologyOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayStudy(StudyProvider study) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estudio de Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTodayStat(Icons.access_time_rounded, '${study.totalMinutesToday}m', 'Tiempo', AppColors.info),
              _buildTodayStat(Icons.repeat_rounded, '${study.sessionsToday}', 'Sesiones', AppColors.success),
              _buildTodayStat(Icons.local_fire_department_rounded, '${study.currentStreakDays}d', 'Racha', AppColors.pharmacologyOrange),
              _buildTodayStat(Icons.school_rounded, '${study.allTimeSessions}', 'Total', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      backgroundColor: AppColors.darkCard,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryPage()));
        else if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()));
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'Biblioteca'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendario'),
      ],
    );
  }
}
