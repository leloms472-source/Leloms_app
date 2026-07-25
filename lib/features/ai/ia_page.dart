import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class IaPage extends StatefulWidget {
  const IaPage({super.key});

  @override
  State<IaPage> createState() => _IaPageState();
}

class _IaPageState extends State<IaPage> {
  final _controller = TextEditingController();
  final _messages = <Map<String, String>>[];
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': _controller.text});
      _isLoading = true;
    });
    _controller.clear();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Soy Leloms, tu asistente de estudio. Estoy aquí para ayudarte a comprender temas de ciencias de la salud. ¿Qué te gustaría repasar hoy?'});
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _QuickActions(),
          const Divider(height: 1),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: AppSpacing.paddingLg,
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))]),
                        );
                      }
                      final msg = _messages[i];
                      final isUser = msg['role'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                padding: AppSpacing.paddingSm,
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                              ),
                              AppSpacing.gapHorizontalSm,
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                                  borderRadius: BorderRadius.circular(12).copyWith(
                                    bottomRight: isUser ? const Radius.circular(4) : null,
                                    bottomLeft: !isUser ? const Radius.circular(4) : null,
                                  ),
                                ),
                                child: Text(
                                  msg['content'] ?? '',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isUser ? Colors.white : (isDark ? AppColors.lightText : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_messages.isNotEmpty) const Divider(height: 1),
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(color: isDark ? AppColors.dark : AppColors.lightBg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Preguntale a Leloms...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                AppSpacing.gapHorizontalSm,
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.summarize, 'label': 'Resumir'},
      {'icon': Icons.quiz, 'label': 'Quiz'},
      {'icon': Icons.style, 'label': 'Flashcard'},
      {'icon': Icons.explore, 'label': 'Explicar'},
    ];
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingLg,
        itemCount: actions.length,
        separatorBuilder: (_, __) => AppSpacing.gapHorizontalMd,
        itemBuilder: (_, i) {
          final a = actions[i];
          return ActionChip(
            avatar: Icon(a['icon'] as IconData, size: 16),
            label: Text(a['label'] as String),
            onPressed: () {},
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
            AppSpacing.gapVerticalLg,
            Text('Asistente de estudio', style: AppTypography.titleLarge),
            AppSpacing.gapVerticalSm,
            Text('Hacé preguntas sobre cualquier tema de ciencias de la salud.',
                style: AppTypography.bodyMedium.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
