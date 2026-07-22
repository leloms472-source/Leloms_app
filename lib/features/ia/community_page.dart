import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/content_repository.dart';
import '../../core/models/subject_model.dart';
import '../help/help_page.dart';

class CommunityPage extends StatefulWidget {
  final String? subject;
  const CommunityPage({super.key, this.subject});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ContentRepository _repo = ContentRepository();
  List<Subject> _subjects = [];
  bool _loading = true;
  String _selectedTab = 'subjects';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final subjects = await _repo.getSubjects();
      if (mounted) setState(() { _subjects = subjects; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.subject ?? 'Comunidad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Necesito ayuda',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage())),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildTabs(),
                Expanded(child: _selectedTab == 'subjects' ? _buildSubjectsView() : _buildHelpView()),
              ],
            ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        _buildTab('subjects', 'Por materia'),
        _buildTab('help', 'Ayuda'),
      ]),
    );
  }

  Widget _buildTab(String id, String label) {
    final selected = _selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildSubjectsView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _subjects.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Discusiones por materia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              const SizedBox(height: 8),
              const Text('Participa en discusiones, comparte recursos y resuelve dudas con otros estudiantes.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
            ]),
          );
        }
        final subject = _subjects[index - 1];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showSubjectDiscussions(subject),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: subject.color.withValues(alpha: 0.2))),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: subject.color.withValues(alpha: 0.15)),
                child: Icon(subject.icon, color: subject.color, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject.name, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.question_answer_rounded, size: 12, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text('Discusiones', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                  const SizedBox(width: 12),
                  Icon(Icons.people_rounded, size: 12, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text('Conectar', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                ]),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSubjectDiscussions(Subject subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject.name, style: const TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sheetOption(Icons.forum_rounded, 'Ver discusiones', AppColors.primary, () {
              Navigator.pop(ctx);
              _showDiscussionThread(subject);
            }),
            _sheetOption(Icons.help_outline_rounded, 'Pedir ayuda', AppColors.pharmacologyOrange, () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage(subject: subject.name)));
            }),
            _sheetOption(Icons.share_rounded, 'Compartir recurso', AppColors.biochemistryGreen, () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compartir recurso - Próximamente')));
            }),
            _sheetOption(Icons.auto_stories_rounded, 'Compartir resumen', AppColors.physiologyBlue, () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compartir resumen - Próximamente')));
            }),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
        child: Icon(icon, color: color, size: 20)),
      title: Text(label, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }

  void _showDiscussionThread(Subject subject) {
    final discussions = [
      {'user': 'María G.', 'question': '¿Alguien tiene un buen mnémotécnico para los pares craneales?', 'replies': 5, 'time': 'Hace 2h'},
      {'user': 'Carlos R.', 'question': 'Diferencia entre conducción saltatoria y continua - ¿me pueden explicar?', 'replies': 3, 'time': 'Hace 5h'},
      {'user': 'Ana L.', 'question': 'Recomienden libros de ${subject.name} por favor', 'replies': 8, 'time': 'Hace 1d'},
      {'user': 'Diego M.', 'question': '¿Cómo estudiar la fisiología del músculo liso?', 'replies': 2, 'time': 'Hace 2d'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('Discusiones - ${subject.name}', style: const TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _askQuestion(subject);
                  },
                ),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: discussions.length,
                  itemBuilder: (_, i) => _buildDiscussionItem(discussions[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.2)),
          child: Center(child: Text((item['user'] as String)[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['question'] as String, style: const TextStyle(color: AppColors.lightText, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(children: [
            Text(item['user'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
            const SizedBox(width: 8),
            Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.secondaryText),
            const SizedBox(width: 2),
            Text('${item['replies']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
            const Spacer(),
            Text(item['time'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10)),
          ]),
        ])),
      ]),
    );
  }

  void _askQuestion(Subject subject) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text('Preguntar en ${subject.name}', style: const TextStyle(color: AppColors.lightText)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: AppColors.lightText),
          decoration: const InputDecoration(
            hintText: 'Escribe tu pregunta...',
            hintStyle: TextStyle(color: AppColors.secondaryText),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pregunta publicada')));
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.help_outline_rounded, size: 80, color: AppColors.secondaryText),
          const SizedBox(height: 16),
          const Text('¿Necesitas ayuda con algún tema?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 8),
          const Text('Encuentra estudiantes que dominan la materia o ayuda a otros.', style: TextStyle(color: AppColors.secondaryText), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage())),
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text('Pedir ayuda'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage(offerHelp: true))),
            icon: const Icon(Icons.volunteer_activism_rounded),
            label: const Text('Ofrecer ayuda'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    );
  }
}
