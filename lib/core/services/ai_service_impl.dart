import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/interfaces/ai_service.dart';

class AiServiceImpl implements IAiService {
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  AiServiceImpl({
    String? apiKey,
    String baseUrl = 'https://api.openai.com/v1',
    String model = 'gpt-4o-mini',
  })  : _apiKey = apiKey ?? '',
        _baseUrl = baseUrl,
        _model = model;

  @override
  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    String? systemPrompt,
  }) async {
    if (_apiKey.isEmpty) return _mockResponse(messages);

    final body = {
      'model': _model,
      'messages': [
        if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['choices'][0]['message']['content'] as String;
    }
    throw Exception('AI request failed: ${response.statusCode}');
  }

  @override
  Future<String> generateSummary(String text) async {
    return sendMessage(
      systemPrompt: 'Sos Leloms, asistente de estudio para ciencias de la salud. Generá un resumen claro del texto.',
      messages: [{'role': 'user', 'content': text}],
    );
  }

  @override
  Future<List<String>> generateKeywords(String text) async {
    final result = await sendMessage(
      systemPrompt: 'Extraé las palabras clave del texto. Respondé solo una lista separada por comas.',
      messages: [{'role': 'user', 'content': text}],
    );
    return result.split(',').map((e) => e.trim()).toList();
  }

  @override
  Future<List<Map<String, String>>> generateFlashcards(String text, {int count = 10}) async {
    final result = await sendMessage(
      systemPrompt: 'Generá $count flashcards en formato: PREGUNTA || RESPUESTA. Una por línea.',
      messages: [{'role': 'user', 'content': text}],
    );
    return result.split('\n').where((l) => l.contains('||')).map((l) {
      final parts = l.split('||');
      return {'question': parts[0].trim(), 'answer': parts[1].trim()};
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> generateQuiz(String text, {int count = 5}) async {
    final result = await sendMessage(
      systemPrompt: 'Generá $count preguntas tipo quiz. Formato JSON: {"question":"...", "options":["a","b","c","d"], "correctAnswer":0}. Respondé SOLO JSON válido, un objeto por línea.',
      messages: [{'role': 'user', 'content': text}],
    );
    return result.split('\n').where((l) => l.trim().startsWith('{')).map((l) {
      return jsonDecode(l.trim()) as Map<String, dynamic>;
    }).toList();
  }

  @override
  Future<String> explain(String topic, String level) async {
    return sendMessage(
      systemPrompt: 'Sos Leloms, tutor de ciencias de la salud. Explicá el tema a nivel $level de forma clara y didáctica.',
      messages: [{'role': 'user', 'content': topic}],
    );
  }

  String _mockResponse(List<Map<String, String>> messages) {
    final last = messages.isNotEmpty ? messages.last['content']?.toLowerCase() ?? '' : '';
    if (last.contains('resum') || last.contains('pdf')) {
      return 'Resumen generado por Leloms. El texto cubre los conceptos fundamentales... (modo mock)';
    }
    if (last.contains('flashcard')) {
      return 'PREGUNTA: ¿Cuál es la función principal? || RESPUESTA: La función principal es...';
    }
    if (last.contains('quiz') || last.contains('pregunta')) {
      return '{"question":"¿Qué estructura...?", "options":["A","B","C","D"], "correctAnswer":0}';
    }
    return 'Soy Leloms, tu asistente de estudio. Estoy en modo offline. Conectá una API key de OpenAI para respuestas completas.';
  }
}
