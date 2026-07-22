import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/academic_repository.dart';
import '../../core/models/subject_model.dart';
import '../../core/models/topic_model.dart';
import '../quiz/quiz_list_page.dart';
import '../flashcard/flashcard_list_page.dart';
import '../exam/exam_config_page.dart';

class TopicDetailPage extends StatefulWidget {
  final Subject subject;
  const TopicDetailPage({super.key, required this.subject});

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final AcademicRepository _repo = AcademicRepository();
  List<Topic> _topics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repo.getTopics(widget.subject.id);
      if (mounted) setState(() { _topics = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _topics.isEmpty
              ? const Center(child: Text('No hay temas disponibles', style: TextStyle(color: AppColors.secondaryText)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _topics.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildResourceGrid();
                    return _buildTopicCard(_topics[index - 1]);
                  },
                ),
    );
  }

  Widget _buildResourceGrid() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recursos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _resourceButton(Icons.quiz_rounded, 'Quizzes', AppColors.physiologyBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizListPage(subject: widget.subject.name)))),
          _resourceButton(Icons.credit_card_rounded, 'Flashcards', AppColors.pharmacologyOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardListPage(subject: widget.subject.name)))),
          _resourceButton(Icons.assignment_rounded, 'Simulacro', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
          _resourceButton(Icons.auto_stories_rounded, 'Resumen', AppColors.biochemistryGreen, null),
        ]),
      ]),
    );
  }

  Widget _resourceButton(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10)),
      ]),
    );
  }

  Widget _buildTopicCard(Topic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showResourceSheet(topic),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: topic.color.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: topic.color.withValues(alpha: 0.15)),
                child: Icon(Icons.topic_rounded, color: topic.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(topic.name, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                if (topic.description != null)
                  Text(topic.description!, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              if (topic.resourcesCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: topic.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('${topic.resourcesCount}', style: TextStyle(color: topic.color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
            ]),
          ),
        ),
      ),
    );
  }

  void _showResourceSheet(Topic topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic.name, style: const TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sheetOption(Icons.quiz_rounded, 'Quizzes', AppColors.physiologyBlue, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => QuizListPage(subject: widget.subject.name))); }),
            _sheetOption(Icons.credit_card_rounded, 'Flashcards', AppColors.pharmacologyOrange, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardListPage(subject: widget.subject.name))); }),
            _sheetOption(Icons.picture_as_pdf_rounded, 'PDFs', AppColors.anatomyRed, null),
            _sheetOption(Icons.auto_stories_rounded, 'Resúmenes', AppColors.biochemistryGreen, null),
            _sheetOption(Icons.question_answer_rounded, 'Preguntas de comunidad', AppColors.primary, null),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(IconData icon, String label, Color color, VoidCallback? onTap) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }
}
