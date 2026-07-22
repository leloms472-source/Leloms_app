import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/profile_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/leloms_cat.dart';
import '../ia/ia_page.dart';
import '../ia/community_page.dart';
import '../library/library_page.dart';
import '../wellness/wellness_page.dart';
import '../calendar/calendar_page.dart';
import '../profile/profile_page.dart';
import '../study/study_timer_page.dart';
import '../analytics/analytics_page.dart';
import '../exam/exam_config_page.dart';
import '../search/global_search_page.dart';
import '../study_plan/study_plan_page.dart';
import '../auth/login_page.dart';
import '../../core/supabase/supabase_client.dart';
import '../career/career_list_page.dart';
import '../topic/no_entiendo_page.dart';
import '../topic/quick_study_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _studyTips = [
    '¿Sabías que estudiar en sesiones de 25 min mejora la retención?',
    'Explicar un tema a otro refuerza tu aprendizaje.',
    'Alterna materias para mantener tu mente activa.',
    'Los descansos cortos ayudan a consolidar la memoria.',
    'Dibujar diagramas mejora la comprensión de procesos.',
  ];

  String get _randomTip => _studyTips[DateTime.now().day % _studyTips.length];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>();
    final study = context.watch<StudyProvider>();

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
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 16),
            LelomsCatBanner(message: _randomTip),
            const SizedBox(height: 24),
            _buildRecommendation(user),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildTodayStats(study),
            const SizedBox(height: 24),
            _buildQuickAccess(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(ProfileProvider user) {
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
              Text('${user.currentXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          _buildDrawerItem(Icons.home_rounded, 'Inicio', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.school_rounded, 'Carreras', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerListPage()))),
          _buildDrawerItem(Icons.checklist_rounded, 'Plan de Estudio', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanPage()))),
          _buildDrawerItem(Icons.assignment_rounded, 'Simulacros', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
          _buildDrawerItem(Icons.show_chart_rounded, 'Progreso', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage()))),
          _buildDrawerItem(Icons.timer_rounded, 'Temporizador', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage()))),
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

  Widget _buildHeader(ProfileProvider user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) { greeting = 'Buenos días'; }
    else if (hour < 18) { greeting = 'Buenas tardes'; }
    else { greeting = 'Buenas noches'; }

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

  Widget _buildRecommendation(ProfileProvider user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const LelomsCat(message: '', size: 36),
          const SizedBox(width: 10),
          const Expanded(child: Text('¿Qué estudio hoy?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        _recommendationChip(Icons.replay_rounded, 'Repasar temas pendientes', AppColors.pharmacologyOrange),
        const SizedBox(height: 8),
        _recommendationChip(Icons.timer_rounded, 'Sesión rápida de 10 min', AppColors.biochemistryGreen),
        const SizedBox(height: 8),
        _recommendationChip(Icons.smart_toy_rounded, 'Preguntar a IA Leloms', AppColors.primaryLight),
      ]),
    );
  }

  Widget _recommendationChip(IconData icon, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final quickItems = [
      _QuickActionData(Icons.timer_outlined, '10 min', 'Estudio rápido', AppColors.biochemistryGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickStudyPage(duration: 10)))),
      _QuickActionData(Icons.timer_rounded, '1 hora', 'Estudio completo', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickStudyPage(duration: 60)))),
      _QuickActionData(Icons.smart_toy_rounded, 'IA Leloms', 'Pregunta lo que sea', AppColors.pharmacologyOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IaPage()))),
      _QuickActionData(Icons.help_outline_rounded, 'No entiendo', 'Explicación simple', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoEntiendoPage()))),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acción Rápida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 12),
      ...quickItems.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: item.color.withValues(alpha: 0.2))),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: item.color.withValues(alpha: 0.15)),
                  child: Icon(item.icon, color: item.color, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(item.subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                ])),
                const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
              ]),
            ),
          ),
        ),
      )),
    ]);
  }

  Widget _buildTodayStats(StudyProvider study) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estudio de Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _statItem(Icons.access_time_rounded, '${study.totalMinutesToday}m', 'Tiempo', AppColors.info),
          _statItem(Icons.repeat_rounded, '${study.sessionsToday}', 'Sesiones', AppColors.success),
          _statItem(Icons.local_fire_department_rounded, '${study.currentStreakDays}d', 'Racha', AppColors.pharmacologyOrange),
          _statItem(Icons.school_rounded, '${study.allTimeSessions}', 'Total', AppColors.primary),
        ]),
      ]),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
    ]);
  }

  Widget _buildQuickAccess() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Explorar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 12),
      Row(children: [
        _quickAccessCard(Icons.school_rounded, 'Carreras', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerListPage()))),
        const SizedBox(width: 8),
        _quickAccessCard(Icons.groups_rounded, 'Comunidad', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage()))),
        const SizedBox(width: 8),
        _quickAccessCard(Icons.assignment_rounded, 'Simulacro', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
      ]),
    ]);
  }

  Widget _quickAccessCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
            child: Column(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)), child: Icon(icon, color: color, size: 22)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
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

class _QuickActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionData(this.icon, this.title, this.subtitle, this.color, this.onTap);
}
