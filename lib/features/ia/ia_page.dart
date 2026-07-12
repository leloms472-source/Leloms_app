import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_service.dart';

class IaPage extends StatefulWidget {
  const IaPage({super.key});

  @override
  State<IaPage> createState() => _IaPageState();
}

class _IaPageState extends State<IaPage> with TickerProviderStateMixin {
  final AiService _aiService = AiService();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String _selectedDifficulty = 'Intermedio';
  bool _apiConfigured = false;

  final List<String> _quickActions = [
    'Resumir PDF',
    'Explicación simple',
    'Crear Quiz',
    'Generar Flashcards',
  ];

  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'type': 'ai',
        'content': '¡Hola! Soy Leloms, tu asistente de estudio. 🐱\n\nPuedo ayudarte con:\n• Resumir PDFs\n• Crear explicaciones simples\n• Generar quizzes\n• Crear flashcards\n\n¿Qué necesitas hoy?',
        'time': _getCurrentTime(),
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'type': 'user',
        'content': text,
        'time': _getCurrentTime(),
      });
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    _conversationHistory.add({'role': 'user', 'content': text});

    final response = await _aiService.sendMessage(messages: _conversationHistory);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _conversationHistory.add({'role': 'assistant', 'content': response});
      _messages.add({
        'type': 'ai',
        'content': response,
        'time': _getCurrentTime(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showApiConfigDialog() {
    final keyController = TextEditingController(text: _aiService.isConfigured ? '' : '');
    final urlController = TextEditingController(text: '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Configurar API', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Conecta tu propio endpoint de OpenAI compatible.\nPuedes usar OpenAI, Azure, Groq, Together, etc.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              style: const TextStyle(color: AppColors.lightText, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'URL Base (opcional)',
                hintText: 'https://api.openai.com/v1',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                labelStyle: const TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              style: const TextStyle(color: AppColors.lightText, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                labelStyle: const TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              _aiService.configure(
                baseUrl: urlController.text.isNotEmpty ? urlController.text : null,
                apiKey: keyController.text.isNotEmpty ? keyController.text : null,
              );
              setState(() => _apiConfigured = _aiService.isConfigured);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Selecciona dificultad', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
              children: ['Básico', 'Intermedio', 'Avanzado'].map((level) {
                final isSelected = _selectedDifficulty == level;
                return ListTile(
                  leading: Radio<String>(
                    value: level,
                    // ignore: deprecated_member_use
                    groupValue: _selectedDifficulty,
                    // ignore: deprecated_member_use
                    onChanged: (_) {
                      setState(() => _selectedDifficulty = level);
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(level, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.lightText)),
                  onTap: () {
                    setState(() => _selectedDifficulty = level);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showPdfUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Subir PDF', style: TextStyle(color: AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file_rounded, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Selecciona un archivo PDF de tu dispositivo', style: TextStyle(color: AppColors.secondaryText), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage('Subí un PDF sobre Anatomía del Sistema Cardiovascular');
              },
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Seleccionar archivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('IA Leloms'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: _apiConfigured ? AppColors.success : AppColors.secondaryText,
            ),
            onPressed: _showApiConfigDialog,
          ),
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: _showDifficultyDialog),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(child: _messages.isEmpty ? _buildEmptyState() : _buildChatList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickActions.map((action) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(action),
                backgroundColor: AppColors.darkCard,
                labelStyle: const TextStyle(color: AppColors.lightText, fontSize: 12),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                onPressed: () => _sendMessage(action),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.pets_rounded, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text('Hola, soy Leloms', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          const SizedBox(height: 8),
          const Text('Tu asistente de estudio inteligente', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['type'] == 'user';
        return _buildMessageBubble(message, isUser);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAiAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.darkCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message['content'], style: const TextStyle(color: AppColors.lightText, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 4),
                  Text(message['time'], style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const Icon(Icons.pets_rounded, size: 20, color: Colors.white),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border,
      ),
      child: const Icon(Icons.person_rounded, size: 20, color: AppColors.lightText),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.15;
                    final value = ((_dotsController.value - delay) % 1.0).abs();
                    final scale = 0.5 + (value * 0.5);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, color: AppColors.primary),
            onPressed: _showPdfUploadDialog,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: AppColors.lightText),
              decoration: InputDecoration(
                hintText: 'Escribe tu duda...',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
