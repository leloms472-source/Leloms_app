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

    _firestore.getQuizzes().then((quizzes) {
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
      if (mounted) setState(() => _results.addAll(matches));
    });

    _firestore.getFlashcards().then((cards) {
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
      if (mounted) setState(() => _results.addAll(matches));
    });

    _firestore.getSubjects().then((subjects) {
      final matches = subjects.where((s) =>
        s.name.toLowerCase().contains(lower)
      ).map((s) => {
        'type': 'subject',
        'title': s.name,
        'subtitle': '',
        'data': null,
        'icon': Icons.folder_rounded,
        'color': AppColors.primary,
      }).toList();
      if (mounted) setState(() => _results.addAll(matches));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
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
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _search,
          style: const TextStyle(color: AppColors.lightText, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Buscar quizzes, flashcards...',
            hintStyle: TextStyle(color: AppColors.secondaryText),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isSearching
          ? (_results.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off_rounded, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('Sin resultados', style: TextStyle(fontSize: 18, color: AppColors.secondaryText)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) => _buildResultItem(_results[index]),
                ))
          : Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_rounded, size: 100, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('Busca en todo tu contenido', style: TextStyle(fontSize: 18, color: AppColors.secondaryText)),
                const SizedBox(height: 8),
                const Text('Quizzes, flashcards, materias y más', style: TextStyle(color: AppColors.secondaryText)),
              ]),
            ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () {
            if (result['type'] == 'quiz') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(quiz: result['data'] as Quiz)));
            } else if (result['type'] == 'flashcard') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardPage(flashcards: [result['data'] as Flashcard], title: 'Flashcard')));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: const BorderRadius.all(Radius.circular(12)), border: Border.all(color: AppColors.border.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: (result['color'] as Color).withValues(alpha: 0.15)),
                child: Icon(result['icon'] as IconData, color: result['color'] as Color, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(result['title'] as String, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14)),
                if ((result['subtitle'] as String).isNotEmpty)
                  Text(result['subtitle'] as String, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
              ])),
              Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText.withValues(alpha: 0.5)),
            ]),
          ),
        ),
      ),
    );
  }
}
