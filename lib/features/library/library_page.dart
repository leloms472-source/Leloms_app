import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../quiz/quiz_list_page.dart';
import '../flashcard/flashcard_list_page.dart';
import '../exam/exam_config_page.dart';
import '../flashcard/review_queue_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _searchQuery = '';
  String _selectedTab = 'subjects';

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Anatomía', 'progress': 0.75, 'resources': 24, 'completed': 18, 'color': AppColors.anatomyRed, 'icon': Icons.monitor_heart_rounded},
    {'name': 'Fisiología', 'progress': 0.60, 'resources': 20, 'completed': 12, 'color': AppColors.physiologyBlue, 'icon': Icons.favorite_rounded},
    {'name': 'Bioquímica', 'progress': 0.80, 'resources': 15, 'completed': 12, 'color': AppColors.biochemistryGreen, 'icon': Icons.science_rounded},
    {'name': 'Farmacología', 'progress': 0.45, 'resources': 18, 'completed': 8, 'color': AppColors.pharmacologyOrange, 'icon': Icons.medication_rounded},
    {'name': 'Histología', 'progress': 0.65, 'resources': 12, 'completed': 8, 'color': AppColors.histologyPurple, 'icon': Icons.grid_view_rounded},
  ];

  final List<Map<String, dynamic>> _recent = [
    {'title': 'Sistema Cardiovascular', 'type': 'pdf', 'subject': 'Anatomía', 'date': 'Hace 2 horas', 'icon': Icons.picture_as_pdf_rounded, 'color': AppColors.anatomyRed},
    {'title': 'Quiz de Anatomía', 'type': 'quiz', 'subject': 'Anatomía', 'date': 'Hace 5 horas', 'icon': Icons.quiz_rounded, 'color': AppColors.physiologyBlue},
    {'title': 'Mapa Mental - Célula', 'type': 'map', 'subject': 'Bioquímica', 'date': 'Ayer', 'icon': Icons.account_tree_rounded, 'color': AppColors.biochemistryGreen},
    {'title': 'Flashcards Farmacología', 'type': 'flashcard', 'subject': 'Farmacología', 'date': 'Hace 2 días', 'icon': Icons.credit_card_rounded, 'color': AppColors.pharmacologyOrange},
  ];

  final int _totalResources = 48;
  final int _completedResources = 23;
  final int _thisWeekResources = 12;

  List<Map<String, dynamic>> get _filteredSubjects {
    if (_searchQuery.isEmpty) return _subjects;
    return _subjects.where((s) => s['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<Map<String, dynamic>> get _filteredRecent {
    if (_searchQuery.isEmpty) return _recent;
    return _recent.where((r) => r['title'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Biblioteca Inteligente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subir material - Próximamente')),
            ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(12),
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
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
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
          _buildProgressOverview(),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Mis Materias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Ver todas', style: TextStyle(color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: 12),
          ..._filteredSubjects.map((subject) => _buildSubjectCard(subject)),
          const SizedBox(height: 24),
          _buildResourceTypes(),
          const SizedBox(height: 24),
          _buildFirestoreSubjects(),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.school_rounded, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progreso General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('$_completedResources/$_totalResources recursos', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: _completedResources / _totalResources,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(Icons.check_circle_rounded, '$_completedResources', 'Completados'),
              _buildStatChip(Icons.auto_graph_rounded, '$_thisWeekResources', 'Esta semana'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (subject['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (subject['color'] as Color).withValues(alpha: 0.2),
            ),
            child: Icon(subject['icon'] as IconData, color: subject['color'] as Color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                const SizedBox(height: 4),
                Text('${subject['completed']}/${subject['resources']} recursos', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: subject['progress'] as double,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(subject['color'] as Color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${((subject['progress'] as double) * 100).toInt()}%',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: subject['color'] as Color),
          ),
        ],
      ),
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
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildResourceType(Icons.picture_as_pdf_rounded, 'PDFs', '24', AppColors.anatomyRed, null),
            _buildResourceType(Icons.quiz_rounded, 'Quizzes', '12', AppColors.physiologyBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizListPage()))),
            _buildResourceType(Icons.account_tree_rounded, 'Mapas', '8', AppColors.biochemistryGreen, null),
            _buildResourceType(Icons.credit_card_rounded, 'Flashcards', '15', AppColors.pharmacologyOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardListPage()))),
            _buildResourceType(Icons.assignment_rounded, 'Simulacros', 'Ilimitado', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamConfigPage()))),
            _buildResourceType(Icons.schedule_rounded, 'Repaso', 'SM-2', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewQueuePage()))),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceType(IconData icon, String label, String count, Color color, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppColors.lightText, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(count, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirestoreSubjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Materias desde Firestore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('LIVE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Conecta Firebase para ver materias en tiempo real', style: TextStyle(color: AppColors.secondaryText)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final subjects = snapshot.data?.docs ?? [];
            if (subjects.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No hay materias en Firestore aún. Agrega datos desde Firebase Console.', style: TextStyle(color: AppColors.secondaryText)),
              );
            }

            return Column(
              children: subjects.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(data['name'] ?? '', style: const TextStyle(color: AppColors.lightText))),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRecent.length,
      itemBuilder: (context, index) {
        final item = _filteredRecent[index];
        return _buildRecentItem(item);
      },
    );
  }

  Widget _buildRecentItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightText)),
                const SizedBox(height: 4),
                Text('${item['subject']} • ${item['date']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText),
            onPressed: () {},
          ),
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
