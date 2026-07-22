import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/secure_storage_service.dart';
import '../admin/admin_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final path = await _secureStorage.readAvatarPath();
    if (path != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Foto de perfil', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Cámara', style: TextStyle(color: AppColors.lightText)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Galería', style: TextStyle(color: AppColors.lightText)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final xFile = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
      if (xFile == null) return;

      final bytes = await xFile.readAsBytes();

      await _secureStorage.saveAvatarPath(xFile.path);

      if (mounted) setState(() {
        _avatarBytes = bytes;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.dark,
            elevation: 0,
            pinned: true,
            title: const Text('Perfil', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.settings_outlined, color: AppColors.lightText), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildHeader(user),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildAccountInfo(),
                const SizedBox(height: 24),
                _buildAdminPanel(),
                const SizedBox(height: 24),
                _buildSettings(),
                const SizedBox(height: 24),
                _buildSupport(),
                const SizedBox(height: 32),
                _buildLogoutButton(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ProfileProvider user) {
    return Column(children: [
      GestureDetector(
        onTap: _pickAvatar,
        child: Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkCard),
            child: ClipOval(
              child: _avatarBytes != null
                  ? Image.memory(_avatarBytes!, fit: BoxFit.cover, width: 92, height: 92)
                  : const Icon(Icons.person_rounded, size: 50, color: AppColors.lightText),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(user.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _buildBadge('Nivel ${user.level}', AppColors.primary),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.tertiary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.tertiary),
            const SizedBox(width: 4),
            Text('${user.streak} días', style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      ]),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${user.currentXp} XP', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            Text('${user.nextLevelXp} XP', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: user.xpProgress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildStatsGrid() {
    const stats = [
      {'icon': Icons.local_fire_department_rounded, 'value': '12', 'label': 'Días', 'color': AppColors.tertiary},
      {'icon': Icons.school_rounded, 'value': '5', 'label': 'Materias', 'color': AppColors.info},
      {'icon': Icons.check_circle_rounded, 'value': '23', 'label': 'Recursos', 'color': AppColors.success},
      {'icon': Icons.emoji_events_rounded, 'value': '4/12', 'label': 'Logros', 'color': AppColors.gold},
    ];

    final crossCount = Responsive.isMobile(context) ? 4 : (Responsive.isTablet(context) ? 4 : 6);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: Responsive.isMobile(context) ? 0.85 : 1.0,
      children: stats.map((stat) {
        return Container(
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
            const SizedBox(height: 8),
            Text(stat['value'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: stat['color'] as Color)),
            Text(stat['label'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10)),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Mi Cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Editar'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ]),
        const SizedBox(height: 16),
        _buildInfoTile(Icons.email_outlined, 'alex@leloms.com'),
        _buildInfoTile(Icons.school_outlined, 'Medicina - 3° Semestre'),
        _buildInfoTile(Icons.account_balance_outlined, 'Universidad Nacional'),
      ]),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.secondaryText),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.lightText, fontSize: 14))),
      ]),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Configuración', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Notificaciones', style: TextStyle(color: AppColors.lightText)),
          subtitle: const Text('Recibir alertas de estudio', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          value: _notificationsEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _notificationsEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Sonidos', style: TextStyle(color: AppColors.lightText)),
          subtitle: const Text('Efectos de sonido en la app', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          value: _soundEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _soundEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Tema Oscuro', style: TextStyle(color: AppColors.lightText)),
          subtitle: const Text('Alternar entre tema claro y oscuro', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          value: context.watch<ThemeProvider>().isDark,
          activeThumbColor: AppColors.primary,
          onChanged: (_) => context.read<ThemeProvider>().toggle(),
        ),
      ]),
    );
  }

  Widget _buildAdminPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.15), borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.purple, size: 20),
        ),
        title: const Text('Panel Admin', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold)),
        subtitle: const Text('Gestionar contenido educativo', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage())),
      ),
    );
  }

  Widget _buildSupport() {
    return Container(
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        ListTile(leading: const Icon(Icons.help_outline_rounded, color: AppColors.secondaryText), title: const Text('Centro de Ayuda', style: TextStyle(color: AppColors.lightText)), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText), onTap: () {}),
        ListTile(leading: const Icon(Icons.description_outlined, color: AppColors.secondaryText), title: const Text('Términos y Condiciones', style: TextStyle(color: AppColors.lightText)), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText), onTap: () {}),
        ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.secondaryText), title: const Text('Política de Privacidad', style: TextStyle(color: AppColors.lightText)), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText), onTap: () {}),
        ListTile(leading: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText), title: const Text('Acerca de LELOMS', style: TextStyle(color: AppColors.lightText)), trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.secondaryText)), onTap: () {}),
      ]),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Cerrar Sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}
