import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../quiz/quiz_list_page.dart';
import '../flashcard/flashcard_list_page.dart';
import '../flashcard/review_queue_page.dart';
import '../exam/exam_config_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _searchQuery = '';
  String _selectedTab = 'subjects';
  final FirestoreService _firestore = FirestoreService();
  int _quizzesCount = 0;
  int _flashcardsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    _firestore.getQuizzes().first.then((q) {
      if (mounted) setState(() => _quizzesCount = q.length);
    });
    _firestore.getFlashcards().first.then((f) {
      if (mounted) setState(() => _flashcardsCount = f.length);
    });
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabs(),
          Expanded(
            child: _selectedTab == 'subjects'
                ? _buildSubjectsView()
                : _selectedTab == 'recent'
                    ? _buildRecentView()
                    : _buildFavoritesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: AppColors.lightText),
          decoration: InputDecoration(
            hintText: 'Buscar materias, recursos...',
            hintStyle: const TextStyle(color: AppColors.secondaryText),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.secondaryText),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Row(
        children: [
          _buildTab('subjects', 'Mis Materias'),
          _buildTab('recent', 'Recientes'),
          _buildTab('favorites', 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label) {
    final isSelected = _selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          )),
        ),
      ),
    );
  }

  Widget _buildSubjectsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFirestoreSubjects(),
          const SizedBox(height: 24),
          _buildResourceTypes(),
          const SizedBox(height: 24),
          _buildLiveSubjects(),
        ],
      ),
    );
  }

  Widget _buildFirestoreSubjects() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonCard(height: 80, lines: 1);
        }

        final subjects = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
                    child: const Icon(Icons.school_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progreso General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('${subjects.length} materias disponibles', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              if (subjects.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: LinearProgressIndicator(
                  value: subjects.where((s) {
                    final data = s.data() as Map<String, dynamic>? ?? {};
                    final progress = (data['progress'] as num?)?.toDouble() ?? 0;
                    return progress > 0;
                  }).length / subjects.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipos de Recursos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          children: [
            _buildResourceType(Icons.quiz_rounded, 'Quizzes', '$_quizzesCount', AppColors.physiologyBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizListPage()))),
            _buildResourceType(Icons.credit_card_rounded, 'Flashcards', '$_flashcardsCount', AppColors.pharmacologyOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardListPage()))),
            _buildResourceType(Icons.schedule_rounded, 'Repaso', 'SM-2', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewQueuePage()))),
            _buildResourceType(Icons.assignment_rounded, 'Simulacros', 'Ilimitado', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
            _buildResourceType(Icons.picture_as_pdf_rounded, 'PDFs', '--', AppColors.anatomyRed, null),
            _buildResourceType(Icons.account_tree_rounded, 'Mapas', '--', AppColors.biochemistryGreen, null),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceType(IconData icon, String label, String count, Color color, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: AppColors.lightText, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(count, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSubjects() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonList(itemCount: 3);
        }

        final subjects = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Materias desde Firestore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: const Text('LIVE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (subjects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: const Text('Agrega materias desde Firebase Console', style: TextStyle(color: AppColors.secondaryText)),
              )
            else
              ...subjects.map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12))),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)),
                        child: const Icon(Icons.folder_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? '', style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                            if (data['description'] != null)
                              Text(data['description'], style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildRecentView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: AppColors.secondaryText),
          SizedBox(height: 16),
          Text('Tu historial aparecerá aquí', style: TextStyle(fontSize: 18, color: AppColors.secondaryText)),
          SizedBox(height: 8),
          Text('Los recursos que visites se guardarán automáticamente', style: TextStyle(color: AppColors.secondaryText), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No tienes favoritos aún', style: TextStyle(fontSize: 18, color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          const Text('Marca recursos como favoritos para acceder rápido', style: TextStyle(color: AppColors.secondaryText), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
