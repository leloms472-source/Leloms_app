import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  final String _userName = 'Alex';
  final int _level = 24;
  final int _currentXp = 1250;
  final int _nextLevelXp = 1500;
  final int _streak = 12;

  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.local_fire_department_rounded, 'value': '12', 'label': 'Días', 'color': const Color(0xFFF97316)},
    {'icon': Icons.school_rounded, 'value': '5', 'label': 'Materias', 'color': const Color(0xFF3B82F6)},
    {'icon': Icons.check_circle_rounded, 'value': '23', 'label': 'Recursos', 'color': const Color(0xFF10B981)},
    {'icon': Icons.emoji_events_rounded, 'value': '4/12', 'label': 'Logros', 'color': const Color(0xFFD4AF37)},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {'icon': Icons.star_rounded, 'unlocked': true, 'color': const Color(0xFFD4AF37)},
    {'icon': Icons.flash_on_rounded, 'unlocked': true, 'color': const Color(0xFF6366F1)},
    {'icon': Icons.book_rounded, 'unlocked': true, 'color': const Color(0xFF10B981)},
    {'icon': Icons.pets_rounded, 'unlocked': true, 'color': const Color(0xFFEC4899)},
    {'icon': Icons.lock_rounded, 'unlocked': false, 'color': const Color(0xFF64748B)},
    {'icon': Icons.lock_rounded, 'unlocked': false, 'color': const Color(0xFF64748B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0B1020),
            elevation: 0,
            pinned: true,
            title: const Text('Perfil', style: TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFFE2E8F0)),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildAccountInfo(),
                  const SizedBox(height: 24),
                  _buildAchievements(),
                  const SizedBox(height: 24),
                  _buildSanctuaryPlaceholder(),
                  const SizedBox(height: 24),
                  _buildSettings(),
                  const SizedBox(height: 24),
                  _buildSupport(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF151B2E),
            ),
            child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFFE2E8F0)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nivel $_level',
                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFF97316)),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak días',
                    style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_currentXp XP', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('$_nextLevelXp XP', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _currentXp / _nextLevelXp,
                  backgroundColor: const Color(0xFF334155),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: _stats.map((stat) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151B2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat['icon'], color: stat['color'], size: 24),
              const SizedBox(height: 8),
              Text(
                stat['value'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: stat['color']),
              ),
              Text(
                stat['label'],
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi Cuenta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoTile(Icons.email_outlined, 'alex@leloms.com'),
          _buildInfoTile(Icons.school_outlined, 'Medicina - 3° Semestre'),
          _buildInfoTile(Icons.account_balance_outlined, 'Universidad Nacional'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Logros Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _achievements.map((ach) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ach['unlocked'] ? ach['color'].withValues(alpha: 0.2) : const Color(0xFF334155),
                ),
                child: Icon(
                  ach['icon'],
                  color: ach['unlocked'] ? ach['color'] : const Color(0xFF64748B),
                  size: 24,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSanctuaryPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.1),
            const Color(0xFFEC4899).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3), width: 1, strokeAlign: BorderSide.strokeAlignOutside),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.pets_rounded, size: 40, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mi Santuario',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu santuario mágico está en construcción.\nMuy pronto podrás cuidar a tu mascota académica.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 16, color: Color(0xFF6366F1)),
                SizedBox(width: 8),
                Text(
                  'Próximamente',
                  style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Notificaciones', style: TextStyle(color: Color(0xFFE2E8F0))),
            subtitle: const Text('Recibir alertas de estudio', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF6366F1),
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Sonidos', style: TextStyle(color: Color(0xFFE2E8F0))),
            subtitle: const Text('Efectos de sonido en la app', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            value: _soundEnabled,
            activeThumbColor: const Color(0xFF6366F1),
            onChanged: (value) => setState(() => _soundEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSupport() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF94A3B8)),
            title: const Text('Centro de Ayuda', style: TextStyle(color: Color(0xFFE2E8F0))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Color(0xFF94A3B8)),
            title: const Text('Términos y Condiciones', style: TextStyle(color: Color(0xFFE2E8F0))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF94A3B8)),
            title: const Text('Política de Privacidad', style: TextStyle(color: Color(0xFFE2E8F0))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
            title: const Text('Acerca de LELOMS', style: TextStyle(color: Color(0xFFE2E8F0))),
            trailing: const Text('v1.0.0', style: TextStyle(color: Color(0xFF64748B))),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Lógica de cerrar sesión
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Cerrar Sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
