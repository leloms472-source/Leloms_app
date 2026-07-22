import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/academic_repository.dart';
import '../../core/models/career_model.dart';
import '../../core/models/subject_model.dart';
import '../topic/topic_detail_page.dart';

class SubjectListPage extends StatefulWidget {
  final Career career;
  const SubjectListPage({super.key, required this.career});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  final AcademicRepository _repo = AcademicRepository();
  List<Subject> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repo.getSubjectsByCareer(widget.career.id);
      if (mounted) setState(() { _subjects = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.career.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _subjects.isEmpty
              ? const Center(child: Text('No hay materias en esta carrera', style: TextStyle(color: AppColors.secondaryText)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) => _buildSubjectCard(_subjects[index]),
                ),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicDetailPage(subject: subject))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: subject.color.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: subject.color.withValues(alpha: 0.15)),
                child: Icon(subject.icon, color: subject.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject.name, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                if (subject.description != null)
                  Text(subject.description!, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subject.topicsCount > 0)
                  Text('${subject.topicsCount} temas', style: const TextStyle(color: AppColors.primary, fontSize: 11)),
              ])),
              if (subject.progress > 0)
                SizedBox(
                  width: 36, height: 36,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(value: subject.progress, strokeWidth: 3, backgroundColor: AppColors.dark, valueColor: AlwaysStoppedAnimation<Color>(subject.color)),
                    Text('${(subject.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.lightText, fontSize: 9)),
                  ]),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
            ]),
          ),
        ),
      ),
    );
  }
}
