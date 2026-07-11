import 'package:flutter/material.dart';

class IaPage extends StatefulWidget {
  const IaPage({super.key});

  @override
  State<IaPage> createState() => _IaPageState();
}

class _IaPageState extends State<IaPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;
  String _selectedDifficulty = 'Intermedio';

  final List<String> _quickActions = [
    'Resumir PDF',
    'Explicación simple',
    'Crear Quiz',
    'Generar Flashcards',
  ];

  @override
  void initState() {
    super.initState();
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

  void _sendMessage(String text) {
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

    // Simular respuesta de IA
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'content': _generateResponse(text),
          'time': _getCurrentTime(),
        });
      });
    });
  }

  String _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    
    if (lower.contains('resumir') || lower.contains('pdf')) {
      return '📄 Perfecto, sube tu PDF y generaré un resumen completo.\n\n**Modo disponible:**\n• Resumen detallado\n• Explicación simple\n\n¿Cuál prefieres?';
    } else if (lower.contains('quiz') || lower.contains('preguntas')) {
      return '📝 ¡Excelente! Puedo crear un quiz de 20 preguntas sobre cualquier tema.\n\n**Nivel de dificultad:**\n• Básico\n• Intermedio\n• Avanzado\n\n¿Sobre qué tema quieres el quiz?';
    } else if (lower.contains('flashcard')) {
      return '🃏 Las flashcards son perfectas para memorizar.\n\nGeneraré tarjetas con:\n• Pregunta al frente\n• Respuesta al reverso\n• Conceptos clave del tema\n\n¿De qué materia necesitas flashcards?';
    } else {
      return 'Entiendo tu pregunta. Para darte la mejor respuesta, ¿podrías ser más específico?\n\nPor ejemplo:\n• "Resumir el PDF de Anatomía"\n• "Crear quiz de Farmacología"\n• "Explicar simple el sistema cardiovascular"';
    }
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        title: const Text('Selecciona dificultad', style: TextStyle(color: Color(0xFFE2E8F0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Básico', 'Intermedio', 'Avanzado'].map((level) {
            return RadioListTile<String>(
              title: Text(level, style: const TextStyle(color: Color(0xFFE2E8F0))),
              value: level,
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() => _selectedDifficulty = value!);
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
        backgroundColor: const Color(0xFF151B2E),
        title: const Text('Subir PDF', style: TextStyle(color: Color(0xFFE2E8F0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file_rounded, size: 60, color: Color(0xFF6366F1)),
            const SizedBox(height: 16),
            const Text(
              'Selecciona un archivo PDF de tu dispositivo',
              style: TextStyle(color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage('Subí un PDF sobre Anatomía del Sistema Cardiovascular');
              },
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Seleccionar archivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('IA Leloms'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial - Próximamente')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showDifficultyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildChatList(),
          ),
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
                backgroundColor: const Color(0xFF151B2E),
                labelStyle: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                side: BorderSide(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                onPressed: () {
                  _sendMessage(action);
                },
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
                colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.pets_rounded, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hola, soy Leloms',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu asistente de estudio inteligente',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
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
                color: isUser ? const Color(0xFF6366F1) : const Color(0xFF151B2E),
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
                  Text(
                    message['content'],
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
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
          colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
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
        color: Color(0xFF334155),
      ),
      child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFFE2E8F0)),
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
              color: const Color(0xFF151B2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
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
        color: const Color(0xFF151B2E),
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
            icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF6366F1)),
            onPressed: _showPdfUploadDialog,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Color(0xFFE2E8F0)),
              decoration: InputDecoration(
                hintText: 'Escribe tu duda...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1)),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
