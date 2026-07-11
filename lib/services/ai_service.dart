import 'dart:convert';
import 'dart:io';
import 'dart:math';

class AiService {
  String _baseUrl = 'https://api.openai.com/v1';
  String? _apiKey;
  String _model = 'gpt-4o-mini';

  static const String _defaultSystemPrompt = '''
Eres Leloms, un asistente de estudio experto para estudiantes de medicina en Latinoamérica.
Hablas español natural y cercano.
Ayudas con: anatomía, fisiología, bioquímica, farmacología, histología, patología.
Puedes crear quizzes, flashcards, resúmenes y explicaciones simples.
Sé conciso, didáctico y preciso.
Usa terminología médica correcta pero explica con claridad.
''';

  void configure({
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    if (baseUrl != null) _baseUrl = baseUrl;
    if (apiKey != null) _apiKey = apiKey;
    if (model != null) _model = model;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    String? systemPrompt,
  }) async {
    if (!isConfigured) {
      await Future.delayed(
        Duration(milliseconds: 1000 + Random().nextInt(2000)),
      );
      return _generateMockResponse(messages);
    }

    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt ?? _defaultSystemPrompt},
        ...messages.map((m) => {
          'role': m['role'],
          'content': m['content'],
        }),
      ],
      'temperature': 0.7,
      'max_tokens': 2048,
    };

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 30);

      final request = await client.postUrl(Uri.parse('$_baseUrl/chat/completions'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.add(utf8.encode(jsonEncode(body)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final choice = choices[0] as Map<String, dynamic>;
          final message = choice['message'] as Map<String, dynamic>;
          return (message['content'] as String?)?.trim() ?? '';
        }
        return 'No se pudo obtener respuesta.';
      } else {
        return 'Error ${response.statusCode}: $responseBody';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  String _generateMockResponse(List<Map<String, String>> messages) {
    final lastMessage = messages.isNotEmpty
        ? (messages.last['content'] ?? '').toLowerCase()
        : '';

    if (lastMessage.contains('resumir') || lastMessage.contains('pdf')) {
      return '📄 *Modo Resumen activado*\n\nSube tu PDF y generaré un resumen detallado con los puntos clave. Dividiré el contenido en:\n• Conceptos principales\n• Datos importantes\n• Relaciones entre temas\n\n¿Cómo prefieres el resumen? (detallado o simple)';
    }
    if (lastMessage.contains('quiz') || lastMessage.contains('preguntas')) {
      return '📝 *Creación de Quiz*\n\nPuedo generar un quiz de 10-20 preguntas sobre el tema que necesites.\n\n**Niveles disponibles:**\n• Básico → Conceptos fundamentales\n• Intermedio → Aplicación clínica\n• Avanzado → Diagnóstico diferencial\n\n¿Sobre qué materia y nivel?';
    }
    if (lastMessage.contains('flashcard')) {
      return '🃏 *Flashcards Interactivas*\n\nPerfecto para memorizar. Crearé tarjetas con:\n```\nFrente: Término/Pregunta\nReverso: Definición/Respuesta\n```\n\n¿De qué tema necesitas flashcards?';
    }
    if (lastMessage.contains('explica') || lastMessage.contains('simple')) {
      return '🔍 *Explicación Simple*\n\nDime el tema exacto que quieres entender y te lo explicaré como si fuera la primera vez que lo escuchas, con analogías y ejemplos clínicos.';
    }

    return '¡Hola! Soy Leloms, tu asistente de estudio 🐱\n\nPuedo ayudarte con:\n\n📄 **Resumir PDFs** → Sube tu material y lo sintetizo\n📝 **Crear Quizzes** → Genero preguntas sobre cualquier tema\n🃏 **Generar Flashcards** → Tarjetas de estudio personalizadas\n🔍 **Explicaciones Simples** → Conceptos médicos claros\n\n¿Qué necesitas estudiar hoy?';
  }
}
