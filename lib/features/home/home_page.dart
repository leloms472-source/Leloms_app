import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/challenge_provider.dart';
import '../ia/ia_page.dart';
import '../ia/community_page.dart';
import '../library/library_page.dart';
import '../wellness/wellness_page.dart';
import '../calendar/calendar_page.dart';
import '../profile/profile_page.dart';
import '../sanctuary/sanctuary_page.dart';
import '../shop/shop_page.dart';
import '../study/study_timer_page.dart';
import '../analytics/analytics_page.dart';
import '../exam/exam_config_page.dart';
import '../search/global_search_page.dart';
import '../study_plan/study_plan_page.dart';
import '../auth/login_page.dart';
import '../../core/supabase/supabase_client.dart';

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
            _buildDailyChallenges(),
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
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.person_rounded, size: 35, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(user.userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Nivel ${user.level} • ${user.currentXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          _buildDrawerItem(Icons.checklist_rounded, 'Plan de Estudio', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanPage()))),
          _buildDrawerItem(Icons.assignment_rounded, 'Simulacros', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
          _buildDrawerItem(Icons.show_chart_rounded, 'Progreso', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage()))),
          _buildDrawerItem(Icons.timer_rounded, 'Temporizador', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage()))),
          _buildDrawerItem(Icons.pets_rounded, 'Santuario', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SanctuaryPage()))),
          _buildDrawerItem(Icons.shopping_bag_rounded, 'Tienda', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage()))),
          _buildDrawerItem(Icons.school_rounded, 'Biblioteca', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryPage()))),
          _buildDrawerItem(Icons.self_improvement_rounded, 'Bienestar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessPage()))),
          _buildDrawerItem(Icons.calendar_month_rounded, 'Calendario', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()))),
          _buildDrawerItem(Icons.person_rounded, 'Perfil', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
          const Divider(color: AppColors.border),
          _buildDrawerItem(Icons.logout_rounded, 'Cerrar sesión', () => _handleSignOut(context), isDestructive: true),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await SupabaseConfig.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
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
    if (hour < 12) { greeting = 'Buenos días'; }
    else if (hour < 18) { greeting = 'Buenas tardes'; }
    else { greeting = 'Buenas noches'; }

    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2)),
          child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$greeting, ${user.userName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          Text(_formattedDate, style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
        ])),
      ],
    );
  }

  String get _formattedDate {
    final now = DateTime.now();
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  Widget _buildLiveStats(UserProvider user, SanctuaryProvider sanctuary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20), const SizedBox(width: 6), Text('Racha: ${user.streak} días', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.pets_rounded, color: Colors.white70, size: 16), const SizedBox(width: 6), Text('Árbol: ${sanctuary.treeStageName}', style: const TextStyle(color: Colors.white70, fontSize: 13))]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(20))), child: Text('Nv. ${user.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            const SizedBox(height: 8),
            Text('${user.currentXp} / ${user.nextLevelXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: LinearProgressIndicator(
            value: user.xpProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acceso Rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildQuickCard(Icons.smart_toy_rounded, 'IA Leloms', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IaPage())))),
        const SizedBox(width: 8),
        Expanded(child: _buildQuickCard(Icons.assignment_rounded, 'Simulacro', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage())))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _buildQuickCard(Icons.timer_rounded, 'Pomodoro', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage())))),
        const SizedBox(width: 8),
        Expanded(child: _buildQuickCard(Icons.groups_rounded, 'Comunidad', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage())))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _buildQuickCard(Icons.shopping_bag_rounded, 'Tienda', AppColors.gold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage())))),
        const SizedBox(width: 8),
        Expanded(child: _buildQuickCard(Icons.pets_rounded, 'Santuario', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SanctuaryPage())))),
      ]),
    ]);
  }

  Widget _buildQuickCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(14)), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildDueReviews() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withValues(alpha: 0.15)), child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Todo al día', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
          Text('Revisa tus flashcards en la biblioteca', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _buildDailyChallenges() {
    final challenges = context.watch<ChallengeProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: challenges.allCompleted ? AppColors.success.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))), child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 18)),
          const SizedBox(width: 10),
          const Text('Desafíos Diarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const Spacer(),
          Text('${challenges.completedCount}/${challenges.totalCount}', style: TextStyle(color: challenges.allCompleted ? AppColors.success : AppColors.secondaryText, fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 14),
        ...challenges.challenges.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: c.isCompleted ? AppColors.success.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: c.isCompleted ? AppColors.success.withValues(alpha: 0.2) : AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(c.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: c.isCompleted ? AppColors.success : AppColors.secondaryText, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(color: AppColors.lightText, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(c.description, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
            ])),
            const SizedBox(width: 8),
            Text('+${c.xpReward} XP', style: TextStyle(color: c.isCompleted ? AppColors.success : AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        )),
        if (challenges.canClaim)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final xp = challenges.claimAllRewards();
                  if (xp > 0 && context.mounted) {
                    context.read<UserProvider>().addXp(xp);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Ganaste $xp XP extra por los desafíos!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
                  }
                },
                icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                label: Text('Reclamar ${challenges.challenges.fold(0, (s, c) => s + c.xpReward)} XP'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildTodayStudy(StudyProvider study) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estudio de Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildTodayStat(Icons.access_time_rounded, '${study.totalMinutesToday}m', 'Tiempo', AppColors.info),
          _buildTodayStat(Icons.repeat_rounded, '${study.sessionsToday}', 'Sesiones', AppColors.success),
          _buildTodayStat(Icons.local_fire_department_rounded, '${study.currentStreakDays}d', 'Racha', AppColors.pharmacologyOrange),
          _buildTodayStat(Icons.school_rounded, '${study.allTimeSessions}', 'Total', AppColors.primary),
        ]),
      ]),
    );
  }

  Widget _buildTodayStat(IconData icon, String value, String label, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
    ]);
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      backgroundColor: AppColors.darkCard,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        if (index == 1) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryPage())); }
        else if (index == 2) { Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())); }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'Biblioteca'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendario'),
      ],
    );
  }
}


