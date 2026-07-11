import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareQuizResult({
    required String quizTitle,
    required int score,
    required int total,
    required int xpGained,
  }) async {
    final text = '''
🎯 *LELOMS - Resultado de Quiz*
📚 $quizTitle
✅ $score/$total (${total > 0 ? (score / total * 100).round() : 0}%)
⭐ +$xpGained XP

¡Sigue estudiando con LELOMS! 🐱
''';
    await Share.share(text, subject: 'Resultado de $quizTitle');
  }

  static Future<void> shareAchievement({
    required String title,
    required String description,
  }) async {
    final text = '''
🏆 *¡Nuevo logro en LELOMS!*
🎖️ $title
📝 $description

Descarga LELOMS y estudia conmigo 🐱
''';
    await Share.share(text, subject: 'Logro: $title');
  }

  static Future<void> shareStreak(int days) async {
    final text = '''
🔥 *Racha de $days días en LELOMS!*
¡No hay quien me pare! 🐱

Descarga LELOMS para estudiar medicina 🏥
''';
    await Share.share(text, subject: 'Racha de $days días');
  }
}
