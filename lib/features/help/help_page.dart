import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/leloms_cat.dart';

class HelpPage extends StatefulWidget {
  final String? subject;
  final bool offerHelp;
  const HelpPage({super.key, this.subject, this.offerHelp = false});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _tab = 'requests';

  final List<Map<String, dynamic>> _helpRequests = [
    {'user': 'Sofía P.', 'subject': 'Anatomía', 'topic': 'Sistema cardiovascular', 'message': 'No entiendo el ciclo cardíaco, especialmente los ruidos cardíacos. ¿Alguien me puede explicar?', 'time': 'Hace 30 min', 'offers': 2, 'urgent': true},
    {'user': 'Luis M.', 'subject': 'Farmacología', 'topic': 'Farmacocinética', 'message': 'Volumen de distribución - ¿alguien tiene una forma fácil de entenderlo?', 'time': 'Hace 2h', 'offers': 1, 'urgent': false},
    {'user': 'Elena R.', 'subject': 'Bioquímica', 'topic': 'Glucólisis', 'message': 'Regulación de la glucólisis, específicamente la PFK-1', 'time': 'Hace 5h', 'offers': 3, 'urgent': false},
    {'user': 'Pedro G.', 'subject': 'Fisiología', 'topic': 'Potencial de acción', 'message': 'Canales iónicos dependientes de voltaje, no logro entenderlos', 'time': 'Hace 1d', 'offers': 0, 'urgent': true},
  ];

  final List<Map<String, dynamic>> _helpers = [
    {'name': 'María G.', 'subjects': ['Anatomía', 'Fisiología'], 'helped': 12, 'rating': 4.8},
    {'name': 'Carlos R.', 'subjects': ['Bioquímica', 'Farmacología'], 'helped': 8, 'rating': 4.6},
    {'name': 'Ana L.', 'subjects': ['Farmacología', 'Histología'], 'helped': 15, 'rating': 4.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.offerHelp ? 'Ofrecer ayuda' : 'Necesito ayuda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showNewRequestDialog,
          ),
        ],
      ),
      body: _tab == 'requests' ? _buildRequestsView() : _buildHelpersView(),
      bottomNavigationBar: _buildTabBar(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: _buildNavTab('requests', 'Solicitudes')),
        Expanded(child: _buildNavTab('helpers', 'Estudiantes')),
      ]),
    );
  }

  Widget _buildNavTab(String id, String label) {
    final selected = _tab == id;
    return GestureDetector(
      onTap: () => setState(() => _tab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildRequestsView() {
    final filtered = widget.subject != null
        ? _helpRequests.where((r) => r['subject'] == widget.subject).toList()
        : _helpRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const LelomsCatBanner(message: 'Aquí puedes pedir ayuda a otros estudiantes. Responde dudas y gana puntos por tu contribución.'),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Solicitudes de ayuda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.pharmacologyOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('${filtered.length}', style: const TextStyle(color: AppColors.pharmacologyOrange, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No hay solicitudes de ayuda para esta materia', style: TextStyle(color: AppColors.secondaryText))),
          )
        else
          ...filtered.map((r) => _buildRequestCard(r)),
      ]),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: request['urgent'] ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.pharmacologyOrange.withValues(alpha: 0.2)),
            child: Center(child: Text((request['user'] as String)[0], style: const TextStyle(color: AppColors.pharmacologyOrange, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(request['user'] as String, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${request['subject']} • ${request['topic']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          ])),
          if (request['urgent'])
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
              child: const Text('URGENTE', style: TextStyle(color: AppColors.error, fontSize: 8, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 10),
        Text(request['message'] as String, style: const TextStyle(color: AppColors.lightText, fontSize: 13)),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.volunteer_activism_rounded, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text('${request['offers']} ofrecen ayuda', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          const Spacer(),
          Text(request['time'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _offerHelp(request),
            icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
            label: const Text('Yo puedo ayudar'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.success, side: const BorderSide(color: AppColors.success), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ]),
    );
  }

  void _offerHelp(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Ofrecer ayuda', style: TextStyle(color: AppColors.lightText)),
        content: const Text('¿Quieres contactar a este estudiante para ayudarlo con su duda?', style: TextStyle(color: AppColors.secondaryText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Te hemos contactado con el estudiante')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Sí, ayudar'),
          ),
        ],
      ),
    );
  }

  void _showNewRequestDialog() {
    final subjectController = TextEditingController(text: widget.subject ?? '');
    final topicController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Pedir ayuda', style: TextStyle(color: AppColors.lightText)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: subjectController,
              style: const TextStyle(color: AppColors.lightText),
              decoration: const InputDecoration(labelText: 'Materia', labelStyle: TextStyle(color: AppColors.secondaryText), border: OutlineInputBorder(), hintText: 'Ej: Anatomía', hintStyle: TextStyle(color: AppColors.secondaryText)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: topicController,
              style: const TextStyle(color: AppColors.lightText),
              decoration: const InputDecoration(labelText: 'Tema', labelStyle: TextStyle(color: AppColors.secondaryText), border: OutlineInputBorder(), hintText: 'Ej: Sistema cardiovascular', hintStyle: TextStyle(color: AppColors.secondaryText)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.lightText),
              decoration: const InputDecoration(labelText: '¿Qué no entiendes?', labelStyle: TextStyle(color: AppColors.secondaryText), border: OutlineInputBorder(), hintText: 'Describe tu duda...', hintStyle: TextStyle(color: AppColors.secondaryText)),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud de ayuda enviada')));
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estudiantes que ayudan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 8),
        const Text('Estudiantes con alto conocimiento en sus materias, dispuestos a ayudar.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
        const SizedBox(height: 16),
        ..._helpers.map((h) => _buildHelperCard(h)),
      ]),
    );
  }

  Widget _buildHelperCard(Map<String, dynamic> helper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
          child: Center(child: Text((helper['name'] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(helper['name'] as String, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Ayudó a ${helper['helped']} estudiantes • ⭐ ${helper['rating']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: (helper['subjects'] as List<String>).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(s, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
      ]),
    );
  }
}
