import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _searchQuery = '';
  String _selectedTab = 'subjects';

  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'Anatomía',
      'progress': 0.75,
      'resources': 24,
      'completed': 18,
      'color': const Color(0xFFEF4444),
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'name': 'Fisiología',
      'progress': 0.60,
      'resources': 20,
      'completed': 12,
      'color': const Color(0xFF3B82F6),
      'icon': Icons.favorite_rounded,
    },
    {
      'name': 'Bioquímica',
      'progress': 0.80,
      'resources': 15,
      'completed': 12,
      'color': const Color(0xFF10B981),
      'icon': Icons.science_rounded,
    },
    {
      'name': 'Farmacología',
      'progress': 0.45,
      'resources': 18,
      'completed': 8,
      'color': const Color(0xFFF59E0B),
      'icon': Icons.medication_rounded,
    },
    {
      'name': 'Histología',
      'progress': 0.65,
      'resources': 12,
      'completed': 8,
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.grid_view_rounded,
    },
  ];

  final List<Map<String, dynamic>> _recent = [
    {
      'title': 'Sistema Cardiovascular',
      'type': 'pdf',
      'subject': 'Anatomía',
      'date': 'Hace 2 horas',
      'icon': Icons.picture_as_pdf_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Quiz de Anatomía',
      'type': 'quiz',
      'subject': 'Anatomía',
      'date': 'Hace 5 horas',
      'icon': Icons.quiz_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Mapa Mental - Célula',
      'type': 'map',
      'subject': 'Bioquímica',
      'date': 'Ayer',
      'icon': Icons.account_tree_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Flashcards Farmacología',
      'type': 'flashcard',
      'subject': 'Farmacología',
      'date': 'Hace 2 días',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFFF59E0B),
    },
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
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('Biblioteca Inteligente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subir material - Próximamente')),
              );
            },
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
          color: const Color(0xFF151B2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Color(0xFFE2E8F0)),
          decoration: InputDecoration(
            hintText: 'Buscar materias, recursos...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)),
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
        color: const Color(0xFF151B2E),
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
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
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
              const Text(
                'Mis Materias',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todas', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._filteredSubjects.map((subject) => _buildSubjectCard(subject)),
          const SizedBox(height: 24),
          _buildResourceTypes(),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
                    const Text(
                      'Progreso General',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_completedResources/$_totalResources recursos',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Container(
                height: 10,
                width: 300 * (_completedResources / _totalResources),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
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
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subject['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: subject['color'].withValues(alpha: 0.2),
            ),
            child: Icon(subject['icon'], color: subject['color'], size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject['completed']}/${subject['resources']} recursos',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: 200.0 * (subject['progress'] as double),
                      decoration: BoxDecoration(
                        color: subject['color'],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(subject['progress'] * 100).toInt()}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: subject['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipos de Recursos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildResourceType(Icons.picture_as_pdf_rounded, 'PDFs', '24', const Color(0xFFEF4444)),
            _buildResourceType(Icons.quiz_rounded, 'Quizzes', '12', const Color(0xFF3B82F6)),
            _buildResourceType(Icons.account_tree_rounded, 'Mapas', '8', const Color(0xFF10B981)),
            _buildResourceType(Icons.credit_card_rounded, 'Flashcards', '15', const Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceType(IconData icon, String label, String count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
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
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  count,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'], color: item['color'], size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['subject']} • ${item['date']}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
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
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: const Color(0xFF64748B).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes favoritos aún',
            style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Marca recursos como favoritos para acceder rápido',
            style: TextStyle(color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
