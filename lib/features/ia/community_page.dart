import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _searchQuery = '';
  String _selectedTab = 'ranking';

  final List<Map<String, dynamic>> _ranking = [
    {'title': 'Sistema Cardiovascular', 'author': 'María G.', 'subject': 'Anatomía', 'votes': 234, 'comments': 18, 'difficulty': 'Intermedio', 'color': AppColors.anatomyRed, 'icon': Icons.favorite_rounded, 'isVoted': false},
    {'title': 'Ciclo de Krebs', 'author': 'Carlos R.', 'subject': 'Bioquímica', 'votes': 189, 'comments': 24, 'difficulty': 'Avanzado', 'color': AppColors.biochemistryGreen, 'icon': Icons.science_rounded, 'isVoted': true},
    {'title': 'Farmacocinética', 'author': 'Ana L.', 'subject': 'Farmacología', 'votes': 156, 'comments': 12, 'difficulty': 'Intermedio', 'color': AppColors.pharmacologyOrange, 'icon': Icons.medication_rounded, 'isVoted': false},
    {'title': 'Sistema Nervioso', 'author': 'Diego M.', 'subject': 'Fisiología', 'votes': 142, 'comments': 31, 'difficulty': 'Básico', 'color': AppColors.physiologyBlue, 'icon': Icons.psychology_rounded, 'isVoted': false},
    {'title': 'Tejido Epitelial', 'author': 'Sofía P.', 'subject': 'Histología', 'votes': 98, 'comments': 7, 'difficulty': 'Básico', 'color': AppColors.histologyPurple, 'icon': Icons.grid_view_rounded, 'isVoted': true},
  ];

  final List<Map<String, dynamic>> _mySummaries = [
    {'title': 'Músculo Cardíaco', 'subject': 'Anatomía', 'votes': 45, 'comments': 3, 'date': 'Hace 2 días', 'color': AppColors.anatomyRed},
    {'title': 'Glucólisis', 'subject': 'Bioquímica', 'votes': 28, 'comments': 1, 'date': 'Hace 5 días', 'color': AppColors.biochemistryGreen},
  ];

  List<Map<String, dynamic>> get _filteredRanking {
    if (_searchQuery.isEmpty) return _ranking;
    return _ranking.where((s) => s['title'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Comunidad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compartir resumen - Próximamente')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabs(),
          Expanded(child: _selectedTab == 'ranking' ? _buildRankingView() : _buildMySummariesView()),
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
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: AppColors.lightText),
          decoration: InputDecoration(
            hintText: 'Buscar resúmenes, temas...',
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
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTab('ranking', 'Ranking'),
          _buildTab('mine', 'Mis Resúmenes'),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label) {
    final selected = _selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
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
            const Text('Top Resúmenes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  const Text('Esta semana', style: TextStyle(color: AppColors.lightText, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._filteredRanking.asMap().entries.map((e) => _buildRankingItem(e.value, e.key + 1)),
      ],
    );
  }

  Widget _buildTopContributors() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.gold, AppColors.pharmacologyOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24), SizedBox(width: 8), Text('Top Contribuidores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildContributor('María G.', 234, 1),
            _buildContributor('Carlos R.', 189, 2),
            _buildContributor('Ana L.', 156, 3),
          ]),
        ],
      ),
    );
  }

  Widget _buildContributor(String name, int votes, int position) {
    return Column(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2), border: Border.all(color: Colors.white, width: 2)),
        child: Center(child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
      ),
      const SizedBox(height: 8),
      Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      Text('$votes votos', style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]);
  }

  Widget _buildRankingItem(Map<String, dynamic> item, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (item['color'] as Color).withValues(alpha: 0.2)),
              child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              const SizedBox(height: 4),
              Row(children: [
                Text('Por ${item['author']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text(item['difficulty'] as String, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
            ])),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: position <= 3 ? AppColors.gold.withValues(alpha: 0.2) : AppColors.border),
              child: Center(child: Text('$position', style: TextStyle(color: position <= 3 ? AppColors.gold : AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _buildActionChip(Icons.thumb_up_rounded, '${item['votes']}', item['isVoted'] ? AppColors.primary : AppColors.secondaryText, () {
              setState(() {
                item['isVoted'] = !item['isVoted'];
                item['votes'] = item['isVoted'] ? item['votes'] + 1 : item['votes'] - 1;
              });
            }),
            const SizedBox(width: 12),
            _buildActionChip(Icons.comment_rounded, '${item['comments']}', AppColors.secondaryText, () {}),
            const Spacer(),
            _buildActionChip(Icons.bookmark_rounded, '', AppColors.secondaryText, () {}),
            const SizedBox(width: 8),
            _buildActionChip(Icons.share_rounded, '', AppColors.secondaryText, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          if (label.isNotEmpty) ...[const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))],
        ]),
      ),
    );
  }

  Widget _buildMySummariesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.2)),
              child: const Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tus Estadísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightText)),
              SizedBox(height: 4),
              Text('2 resúmenes • 73 votos totales', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Mis Resúmenes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 12),
        ..._mySummaries.map((item) => _buildMySummaryItem(item)),
      ],
    );
  }

  Widget _buildMySummaryItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: (item['color'] as Color).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.description_rounded, color: item['color'] as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const SizedBox(height: 4),
            Text('${item['subject']} • ${item['date']}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          ])),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText), onPressed: () {}),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _buildActionChip(Icons.thumb_up_rounded, '${item['votes']}', AppColors.primary, () {}),
          const SizedBox(width: 8),
          _buildActionChip(Icons.comment_rounded, '${item['comments']}', AppColors.secondaryText, () {}),
          const Spacer(),
          _buildActionChip(Icons.edit_rounded, '', AppColors.secondaryText, () {}),
        ]),
      ]),
    );
  }
}
