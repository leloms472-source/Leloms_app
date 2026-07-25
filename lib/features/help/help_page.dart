import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda entre estudiantes'),
        actions: [
          TextButton.icon(
            onPressed: () => _showRequestDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Pedir ayuda'),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TabButton(label: 'Solicitudes', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              ),
              Expanded(
                child: _TabButton(label: 'Ayudantes', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: _tab == 0 ? _RequestsList(isDark: isDark) : _HelpersList(isDark: isDark),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pedir ayuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Materia'),
              onChanged: (_) {},
            ),
            AppSpacing.gapVerticalMd,
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(labelText: '¿Qué necesitás?'),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Enviar')),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          border: selected ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: AppTypography.labelLarge.copyWith(color: selected ? AppColors.primary : AppColors.secondaryText)),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final bool isDark;
  const _RequestsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {'subject': 'Anatomía', 'question': '¿Alguien me explica el sistema linfático?', 'by': 'Camila', 'status': 'Abierto'},
      {'subject': 'Fisiología', 'question': 'Duda sobre potencial de acción', 'by': 'Tomás', 'status': 'En curso'},
    ];
    return ListView.separated(
      padding: AppSpacing.paddingLg,
      itemCount: requests.length,
      separatorBuilder: (_, __) => AppSpacing.gapVerticalSm,
      itemBuilder: (_, i) {
        final r = requests[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text((r['by'] as String)[0], style: const TextStyle(color: AppColors.primary)),
            ),
            title: Text(r['question'] as String, style: AppTypography.titleSmall),
            subtitle: Text('${r['subject']} • ${r['status']}',
                style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.secondaryText),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _HelpersList extends StatelessWidget {
  final bool isDark;
  const _HelpersList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final helpers = [
      {'name': 'María G.', 'subject': 'Anatomía', 'helped': 24},
      {'name': 'Carlos L.', 'subject': 'Fisiología', 'helped': 18},
      {'name': 'Ana R.', 'subject': 'Bioquímica', 'helped': 15},
    ];
    return ListView.separated(
      padding: AppSpacing.paddingLg,
      itemCount: helpers.length,
      separatorBuilder: (_, __) => AppSpacing.gapVerticalSm,
      itemBuilder: (_, i) {
        final h = helpers[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withValues(alpha: 0.15),
              child: Text((h['name'] as String)[0], style: const TextStyle(color: AppColors.success)),
            ),
            title: Text(h['name'] as String, style: AppTypography.titleSmall),
            subtitle: Text('${h['subject']} • ${h['helped']} estudiantes ayudados',
                style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
            trailing: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
            onTap: () {},
          ),
        );
      },
    );
  }
}
