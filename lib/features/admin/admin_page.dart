import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import 'create_quiz_page.dart';
import 'create_flashcard_page.dart';
import '../../widgets/menu_card.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          MenuCard(
            icon: Icons.quiz_rounded,
            title: 'Crear Quiz',
            description: 'Añade preguntas de opción múltiple con respuestas y explicaciones',
            color: AppColors.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQuizPage())),
          ),
          const SizedBox(height: 12),
          MenuCard(
            icon: Icons.credit_card_rounded,
            title: 'Crear Flashcard',
            description: 'Añade tarjetas de estudio con anverso y reverso',
            color: AppColors.secondary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateFlashcardPage())),
          ),
          const SizedBox(height: 12),
          MenuCard(
            icon: Icons.book_rounded,
            title: 'Gestionar Asignaturas',
            description: 'Añade o edita las asignaturas disponibles',
            color: AppColors.success,
            onTap: () => _showCreateSubjectDialog(context),
          ),
          const SizedBox(height: 12),
          _buildContentStats(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.purple, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Admin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Gestiona el contenido educativo', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentStats(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, quizSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('flashcards').snapshots(),
          builder: (context, cardSnap) {
            final quizCount = quizSnap.data?.docs.length ?? 0;
            final cardCount = cardSnap.data?.docs.length ?? 0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.quiz_rounded, '$quizCount', 'Quizzes', AppColors.primary),
                  const Container(width: 1, height: 40, color: AppColors.border),
                  _buildStat(Icons.credit_card_rounded, '$cardCount', 'Flashcards', AppColors.secondary),
                  const Container(width: 1, height: 40, color: AppColors.border),
                  _buildStat(Icons.book_rounded, '${quizCount + cardCount}', 'Total', AppColors.success),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
      ],
    );
  }

  void _showCreateSubjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final colorCtrl = TextEditingController(text: '0xFF6366F1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva Asignatura', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.lightText),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: const TextStyle(color: AppColors.secondaryText),
                hintText: 'Ej: Anatomía',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: colorCtrl,
              style: const TextStyle(color: AppColors.lightText),
              decoration: InputDecoration(
                labelText: 'Color (hex)',
                labelStyle: const TextStyle(color: AppColors.secondaryText),
                hintText: '0xFF6366F1',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final color = int.tryParse(colorCtrl.text.replaceAll('0x', ''), radix: 16) ?? 0xFF6366F1;
              await FirebaseFirestore.instance.collection('subjects').add({
                'name': nameCtrl.text.trim(),
                'color': color,
                'progress': 0.0,
                'resources': 0,
                'completed': 0,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Asignatura "${nameCtrl.text.trim()}" creada'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
