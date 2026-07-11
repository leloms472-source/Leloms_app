import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/flashcard.dart';
import '../../providers/sanctuary_provider.dart';

class FlashcardPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String title;

  const FlashcardPage({
    super.key,
    required this.flashcards,
    this.title = 'Flashcards',
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _learnedCount = 0;
  final Set<int> _learnedSet = {};
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _frontRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: pi / 2, end: pi / 2), weight: 50.0),
    ]).animate(_flipController);
    _backRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: -pi / 2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 50.0),
    ]).animate(_flipController);
  }

  void _toggleFlip() {
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _markLearned() {
    if (!_learnedSet.contains(_currentIndex)) {
      _learnedSet.add(_currentIndex);
      _learnedCount++;
      widget.flashcards[_currentIndex].isLearned = true;
    }
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    context.read<SanctuaryProvider>().addStudyXp(_learnedCount * 3);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('¡Sesión completada!', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Repasaste ${widget.flashcards.length} flashcards',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              '$_learnedCount aprendidas',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ganaste ${_learnedCount * 3} XP',
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Cerrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.flashcards.isEmpty
        ? 1.0
        : (_currentIndex + 1) / widget.flashcards.length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_learnedCount ✅',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          ClipRRect(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.darkCard,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _isFlipped = false;
                  _flipController.reset();
                });
              },
              itemCount: widget.flashcards.length,
              itemBuilder: (context, index) {
                return _buildFlashcard(widget.flashcards[index], index);
              },
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildFlashcard(Flashcard card, int index) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: _toggleFlip,
        child: AnimatedBuilder(
          animation: _flipController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildCardSide(
                  text: card.front,
                  color: AppColors.primary,
                  label: 'Término',
                  rotation: _frontRotation.value,
                  isVisible: _flipController.value < 0.5,
                ),
                _buildCardSide(
                  text: card.back,
                  color: AppColors.secondary,
                  label: 'Definición',
                  rotation: _backRotation.value,
                  isVisible: _flipController.value >= 0.5,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardSide({
    required String text,
    required Color color,
    required String label,
    required double rotation,
    required bool isVisible,
  }) {
    return Opacity(
      opacity: isVisible ? 1.0 : 0.0,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(rotation),
        alignment: FractionalOffset.center,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Toca para voltear',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.refresh_rounded,
              label: 'Repetir',
              color: AppColors.pharmacologyOrange,
              onTap: _nextCard,
            ),
            _buildControlButton(
              icon: Icons.visibility_rounded,
              label: _isFlipped ? 'Ocultar' : 'Ver',
              color: AppColors.primary,
              onTap: _toggleFlip,
            ),
            _buildControlButton(
              icon: Icons.check_circle_rounded,
              label: 'Aprendida',
              color: AppColors.success,
              onTap: _markLearned,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
