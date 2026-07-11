import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showToast = false;

  final List<Map<String, dynamic>> _todayTasks = [
    {'title': 'Examen de Anatomía', 'subtitle': 'Sistema Cardiovascular • 3 días', 'color': AppColors.error, 'icon': Icons.warning_amber_rounded},
    {'title': 'Entrega de Reporte', 'subtitle': 'Bioquímica • Mañana 23:59', 'color': AppColors.warning, 'icon': Icons.assignment_rounded},
    {'title': 'Clase de Fisiología', 'subtitle': 'Lab 105 • 10:00 AM', 'color': AppColors.info, 'icon': Icons.science_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _simulateToast();
  }

  void _simulateToast() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showToast = true);
        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showToast = false);
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      drawer: _buildDrawer(user),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.lightText),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildStatsCard(user),
                const SizedBox(height: 24),
                _buildMainActions(),
                const SizedBox(height: 24),
                _buildTodaySection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_showToast) _buildToast(),
        ],
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, size: 35, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  user.userName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nivel ${user.level} • ${user.currentXp} XP',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
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
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
          ),
          child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buenos días, ${user.userName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText),
              ),
              const Text(
                'Martes, 10 de Junio',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(UserProvider user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Racha actual', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${user.streak} días seguidos', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Nivel ${user.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${user.currentXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${user.nextLevelXp} XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _buildMainActions() {
    return Column(
      children: [
        _buildBigActionCard(
          icon: Icons.smart_toy_rounded,
          title: 'IA Leloms',
          subtitle: 'Tu asistente inteligente',
          gradient: const [AppColors.primary, AppColors.primaryLight],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IaPage())),
        ),
        const SizedBox(height: 12),
        _buildBigActionCard(
          icon: Icons.groups_rounded,
          title: 'Comunidad',
          subtitle: 'Ranking y resúmenes',
          gradient: const [AppColors.secondary, AppColors.secondaryLight],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage())),
        ),
        const SizedBox(height: 12),
        _buildBigActionCard(
          icon: Icons.timer_rounded,
          title: 'Temporizador',
          subtitle: 'Pomodoro y sesiones',
          gradient: const [AppColors.success, AppColors.lime],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTimerPage())),
        ),
      ],
    );
  }

  Widget _buildBigActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Para Hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())),
              child: const Text('Ver todo', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._todayTasks.map((task) => _buildTaskItem(task)),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: task['color'], width: 4)),
      ),
      child: Row(
        children: [
          Icon(task['icon'], color: task['color'], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.lightText)),
                const SizedBox(height: 4),
                Text(task['subtitle'], style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToast() {
    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '📚 Alguien subió material nuevo en Anatomía',
                style: const TextStyle(color: AppColors.lightText, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      backgroundColor: AppColors.darkCard,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'Biblioteca'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendario'),
      ],
    );
  }
}
