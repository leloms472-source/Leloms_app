import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/repositories/academic_repository.dart';
import '../../core/models/career_model.dart';
import '../subject/subject_list_page.dart';

class CareerListPage extends StatefulWidget {
  const CareerListPage({super.key});

  @override
  State<CareerListPage> createState() => _CareerListPageState();
}

class _CareerListPageState extends State<CareerListPage> {
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
        title: const Text('Elige tu carrera'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _careers.isEmpty
              ? const Center(child: Text('No hay carreras disponibles', style: TextStyle(color: AppColors.secondaryText)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.gridColumns(context),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _careers.length,
                  itemBuilder: (context, index) => _buildCareerCard(_careers[index]),
                ),
    );
  }

  Widget _buildCareerCard(Career career) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectListPage(career: career))),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: career.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: career.color.withValues(alpha: 0.15)),
                child: Icon(career.icon, color: career.color, size: 28),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(career.name, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
              ),
              if (career.subjectCount > 0) ...[
                const SizedBox(height: 4),
                Text('${career.subjectCount} materias', style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
