import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../quiz/quiz_page.dart';
import '../flashcard/flashcard_page.dart';
import '../../models/quiz.dart';
import '../../models/flashcard.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  final FirestoreService _firestore = FirestoreService();

  void _search(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _results = [];
    });

    if (query.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    final lower = query.toLowerCase();

    _firestore.getQuizzes().first.then((quizzes) {
      final matches = quizzes.where((q) =>
        q.title.toLowerCase().contains(lower) ||
        q.subject.toLowerCase().contains(lower)
      ).map((q) => {
        'type': 'quiz',
        'title': q.title,
        'subtitle': q.subject,
        'data': q,
        'icon': Icons.quiz_rounded,
        'color': AppColors.physiologyBlue,
      }).toList();
      setState(() => _results.addAll(matches));
    });

    _firestore.getFlashcards().first.then((cards) {
      final matches = cards.where((c) =>
        c.front.toLowerCase().contains(lower) ||
        c.back.toLowerCase().contains(lower) ||
        c.subject.toLowerCase().contains(lower)
      ).map((c) => {
        'type': 'flashcard',
        'title': c.front,
        'subtitle': c.subject,
        'data': c,
        'icon': Icons.credit_card_rounded,
        'color': AppColors.pharmacologyOrange,
      }).toList();
      setState(() => _results.addAll(matches));
    });

    _firestore.getSubjects().first.then((subjects) {
      final matches = subjects.where((s) =>
        s.name.toLowerCase().contains(lower)
      ).map((s) => {
        'type': 'subject',
        'title': s.name,
        'subtitle': 'Materia',
        'icon': Icons.folder_rounded,
        'color': AppColors.primary,
      }).toList();
      setState(() => _results.addAll(matches));
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _isSearching ? _buildResults() : _buildEmptyState()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.lightText, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar materias, quizzes, flashcards...',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                fillColor: AppColors.dark,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.secondaryText),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Sin resultados', style: TextStyle(color: AppColors.secondaryText, fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return _buildResultItem(item);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () {
            final type = item['type'] as String;
            if (type == 'quiz') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuizPage(quiz: item['data'] as Quiz),
              ));
            } else if (type == 'flashcard') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => FlashcardPage(flashcards: [item['data'] as Flashcard], title: item['title'] as String),
              ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(item['subtitle'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(item['type'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Buscar en todo el contenido', style: TextStyle(color: AppColors.secondaryText, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Materias • Quizzes • Flashcards', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
        ],
      ),
    );
  }
}
