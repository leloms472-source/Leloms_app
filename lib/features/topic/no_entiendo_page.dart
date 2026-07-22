import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_service.dart';
import '../../widgets/leloms_cat.dart';

class NoEntiendoPage extends StatefulWidget {
  const NoEntiendoPage({super.key});

  @override
  State<NoEntiendoPage> createState() => _NoEntiendoPageState();
}

class _NoEntiendoPageState extends State<NoEntiendoPage> {
  final TextEditingController _controller = TextEditingController();
  final AiService _ai = AiService();
  String? _response;
  bool _loading = false;
  String _selectedLevel = 'fácil';

  static const _levels = ['fácil', 'paso a paso', 'con ejemplos', 'analogía', 'principiante'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;

    setState(() { _loading = true; _response = null; });

    final prompt = 'Explica "$topic" de forma $_selectedLevel. '
        'Usa terminología precisa pero comprensible. '
        'Si aplica, incluye ejemplo clínico o analogía.';

    final response = await _ai.sendMessage(messages: [
      {'role': 'user', 'content': prompt},
    ], systemPrompt: _systemPrompt);

    if (mounted) setState(() { _response = response; _loading = false; });
  }

  static const _systemPrompt = '''
Eres Leloms, un tutor de estudio experto.
Tu misión es explicar conceptos médicos/complejos de forma clara y didáctica.
Adaptas el nivel de profundidad según lo solicite el estudiante.
Usas analogías, ejemplos clínicos y lenguaje sencillo.
Siempre validas la información y aclaras cuando algo no es seguro.
Hablas en español natural y cercano.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('No entiendo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LelomsCatBanner(message: 'Dime qué tema no entiendes y te lo explico como tú prefieras'),
            const SizedBox(height: 20),
            _buildLevelSelector(),
            const SizedBox(height: 16),
            _buildInput(),
            if (_loading) const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
            if (_response != null) _buildResponse(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('¿Cómo lo explico?', style: TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _levels.map((level) {
          final selected = _selectedLevel == level;
          return GestureDetector(
            onTap: () => setState(() => _selectedLevel = level),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(level, style: TextStyle(color: selected ? Colors.white : AppColors.secondaryText, fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildInput() {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
        child: TextField(
          controller: _controller,
          maxLines: 3,
          style: const TextStyle(color: AppColors.lightText),
          decoration: const InputDecoration(
            hintText: 'Escribe el tema que no entiendes...',
            hintStyle: TextStyle(color: AppColors.secondaryText),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _ask,
          icon: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(_loading ? 'Pensando...' : 'Explicar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]);
  }

  Widget _buildResponse() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Explicación', style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Text(_response!, style: const TextStyle(color: AppColors.lightText, fontSize: 14, height: 1.5)),
      ]),
    );
  }
}
