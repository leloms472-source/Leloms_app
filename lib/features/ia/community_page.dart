import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _searchQuery = '';
  String _selectedTab = 'ranking';

  final List<Map<String, dynamic>> _ranking = [
    {
      'title': 'Sistema Cardiovascular',
      'author': 'María G.',
      'subject': 'Anatomía',
      'votes': 234,
      'comments': 18,
      'difficulty': 'Intermedio',
      'color': const Color(0xFFEF4444),
      'icon': Icons.favorite_rounded,
      'isVoted': false,
    },
    {
      'title': 'Ciclo de Krebs',
      'author': 'Carlos R.',
      'subject': 'Bioquímica',
      'votes': 189,
      'comments': 24,
      'difficulty': 'Avanzado',
      'color': const Color(0xFF10B981),
      'icon': Icons.science_rounded,
      'isVoted': true,
    },
    {
      'title': 'Farmacocinética',
      'author': 'Ana L.',
      'subject': 'Farmacología',
      'votes': 156,
      'comments': 12,
      'difficulty': 'Intermedio',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.medication_rounded,
      'isVoted': false,
    },
    {
      'title': 'Sistema Nervioso',
      'author': 'Diego M.',
      'subject': 'Fisiología',
      'votes': 142,
      'comments': 31,
      'difficulty': 'Básico',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.psychology_rounded,
      'isVoted': false,
    },
    {
      'title': 'Tejido Epitelial',
      'author': 'Sofía P.',
      'subject': 'Histología',
      'votes': 98,
      'comments': 7,
      'difficulty': 'Básico',
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.grid_view_rounded,
      'isVoted': true,
    },
  ];

  final List<Map<String, dynamic>> _mySummaries = [
    {
      'title': 'Músculo Cardíaco',
      'subject': 'Anatomía',
      'votes': 45,
      'comments': 3,
      'date': 'Hace 2 días',
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Glucólisis',
      'subject': 'Bioquímica',
      'votes': 28,
      'comments': 1,
      'date': 'Hace 5 días',
      'color': const Color(0xFF10B981),
    },
  ];

  List<Map<String, dynamic>> get _filteredRanking {
    if (_searchQuery.isEmpty) return _ranking;
    return _ranking.where((s) => s['title'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('Comunidad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir resumen - Próximamente')),
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
            child: _selectedTab == 'ranking'
                ? _buildRankingView()
                : _buildMySummariesView(),
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
            hintText: 'Buscar resúmenes, temas...',
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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'ranking'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'ranking' ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ranking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 'ranking' ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'mine'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'mine' ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mis Resúmenes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 'mine' ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTopContributors(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'Top Resúmenes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF151B2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  const Text('Esta semana', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._filteredRanking.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildRankingItem(item, index + 1);
        }).toList(),
      ],
    );
  }

  Widget _buildTopContributors() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Top Contribuidores',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContributor('María G.', 234, 1),
              _buildContributor('Carlos R.', 189, 2),
              _buildContributor('Ana L.', 156, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributor(String name, int votes, int position) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          '$votes votos',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item['color'].withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item['color'].withValues(alpha: 0.2),
                ),
                child: Icon(item['icon'], color: item['color'], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Por ${item['author']}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['difficulty'],
                            style: const TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: position <= 3 ? const Color(0xFFD4AF37).withValues(alpha: 0.2) : const Color(0xFF334155),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: TextStyle(
                      color: position <= 3 ? const Color(0xFFD4AF37) : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionChip(
                Icons.thumb_up_rounded,
                '${item['votes']}',
                item['isVoted'] ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                () {
                  setState(() {
                    item['isVoted'] = !item['isVoted'];
                    item['votes'] = item['isVoted'] ? item['votes'] + 1 : item['votes'] - 1;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                Icons.comment_rounded,
                '${item['comments']}',
                const Color(0xFF94A3B8),
                () {},
              ),
              const Spacer(),
              _buildActionChip(
                Icons.bookmark_rounded,
                '',
                const Color(0xFF94A3B8),
                () {},
              ),
              const SizedBox(width: 8),
              _buildActionChip(
                Icons.share_rounded,
                '',
                const Color(0xFF94A3B8),
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMySummariesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151B2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.auto_graph_rounded, color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tus Estadísticas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2 resúmenes • 73 votos totales',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Mis Resúmenes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
        ),
        const SizedBox(height: 12),
        ..._mySummaries.map((item) => _buildMySummaryItem(item)).toList(),
      ],
    );
  }

  Widget _buildMySummaryItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item['color'].withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item['color'].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description_rounded, color: item['color'], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionChip(Icons.thumb_up_rounded, '${item['votes']}', const Color(0xFF6366F1), () {}),
              const SizedBox(width: 8),
              _buildActionChip(Icons.comment_rounded, '${item['comments']}', const Color(0xFF94A3B8), () {}),
              const Spacer(),
              _buildActionChip(Icons.edit_rounded, '', const Color(0xFF94A3B8), () {}),
            ],
          ),
        ],
      ),
    );
  }
}
