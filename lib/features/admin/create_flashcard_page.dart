import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/content_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/models/flashcard_model.dart';

class CreateFlashcardPage extends StatefulWidget {
  const CreateFlashcardPage({super.key});

  @override
  State<CreateFlashcardPage> createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {
  final ContentRepository _contentRepo = ContentRepository();
  final _frontCtrl = TextEditingController();
  final _backCtrl = TextEditingController();
  String _selectedSubject = 'Anatomía';
  final List<String> _subjects = const [
    'Anatomía', 'Fisiología', 'Bioquímica', 'Farmacología', 'Histología', 'Patología',
  ];
  bool _saving = false;

  @override
  void dispose() {
    _frontCtrl.dispose();
    _backCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_frontCtrl.text.trim().isEmpty || _backCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa ambos campos'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userId = AuthRepository().currentUser?.id;
      final flashcard = FlashcardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        front: _frontCtrl.text.trim(),
        back: _backCtrl.text.trim(),
        subject: _selectedSubject,
      );
      await _contentRepo.addFlashcard(flashcard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard creada'), backgroundColor: AppColors.success),
        );
        _frontCtrl.clear();
        _backCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Crear Flashcard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, color: AppColors.primary),
            label: const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Anverso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                child: TextField(controller: _frontCtrl, style: const TextStyle(color: AppColors.lightText, fontSize: 16), maxLines: 5, decoration: const InputDecoration(hintText: 'Término, concepto o pregunta...', hintStyle: TextStyle(color: AppColors.secondaryText), border: InputBorder.none)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Reverso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2))),
                child: TextField(controller: _backCtrl, style: const TextStyle(color: AppColors.lightText, fontSize: 16), maxLines: 5, decoration: const InputDecoration(hintText: 'Definición, respuesta o explicación...', hintStyle: TextStyle(color: AppColors.secondaryText), border: InputBorder.none)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            dropdownColor: AppColors.darkCard,
            style: const TextStyle(color: AppColors.lightText),
            decoration: const InputDecoration(labelText: 'Asignatura', labelStyle: TextStyle(color: AppColors.secondaryText), filled: true, fillColor: AppColors.darkCard),
            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
          ),
        ],
      ),
    );
  }
}
