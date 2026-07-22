import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/repositories/academic_repository.dart';
import '../../core/models/career_model.dart';
import '../career/career_list_page.dart';
import '../subject/subject_list_page.dart';
import '../quiz/quiz_list_page.dart';
import '../flashcard/flashcard_list_page.dart';
import '../exam/exam_config_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final AcademicRepository _repo = AcademicRepository();
  List<Career> _careers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repo.getCareers();
      if (mounted) setState(() { _careers = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Biblioteca Inteligente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildResourceGrid(),
                  const SizedBox(height: 24),
                  _buildCareersSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
            child: const Icon(Icons.school_rounded, size: 32, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Organiza tu estudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${_careers.length} carreras disponibles', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
        ]),
      ]),
    );
  }

  Widget _buildResourceGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recursos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: Responsive.gridColumns(context),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
        children: [
          _resourceCard(Icons.quiz_rounded, 'Quizzes', AppColors.physiologyBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizListPage()))),
          _resourceCard(Icons.credit_card_rounded, 'Flashcards', AppColors.pharmacologyOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardListPage()))),
          _resourceCard(Icons.assignment_rounded, 'Simulacros', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
          _resourceCard(Icons.explore_rounded, 'Explorar', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerListPage()))),
        ],
      ),
    ]);
  }

  Widget _resourceCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
              child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.lightText, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildCareersSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Tus carreras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const Spacer(),
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerListPage())),
          icon: const Icon(Icons.explore_rounded, size: 16),
          label: const Text('Ver todas'),
        ),
      ]),
      const SizedBox(height: 8),
      if (_careers.isEmpty)
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('No hay carreras disponibles', style: TextStyle(color: AppColors.secondaryText))),
        )
      else
        ..._careers.map((career) => _buildCareerCard(career)),
    ]);
  }

  Widget _buildCareerCard(Career career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectListPage(career: career))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: career.color.withValues(alpha: 0.2))),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: career.color.withValues(alpha: 0.15)),
                child: Icon(career.icon, color: career.color, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(career.name, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                if (career.description != null) Text(career.description!, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              if (career.subjectCount > 0)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: career.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('${career.subjectCount}', style: TextStyle(color: career.color, fontSize: 11, fontWeight: FontWeight.bold))),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
            ]),
          ),
        ),
      ),
    );
  }
}
