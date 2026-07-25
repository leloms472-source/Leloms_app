abstract class IAiService {
  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    String? systemPrompt,
  });

  Future<String> generateSummary(String text);
  Future<List<String>> generateKeywords(String text);
  Future<List<Map<String, String>>> generateFlashcards(String text, {int count = 10});
  Future<List<Map<String, dynamic>>> generateQuiz(String text, {int count = 5});
  Future<String> explain(String topic, String level);
}
