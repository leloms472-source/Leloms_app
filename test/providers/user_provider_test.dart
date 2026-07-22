import 'package:flutter_test/flutter_test.dart';
import 'package:leloms_app/providers/profile_provider.dart';

void main() {
  late ProfileProvider provider;

  setUp(() {
    provider = ProfileProvider();
  });

  group('ProfileProvider', () {
    test('initial values are correct', () {
      expect(provider.userName, 'Estudiante');
      expect(provider.level, 1);
      expect(provider.currentXp, 0);
      expect(provider.nextLevelXp, 100);
      expect(provider.streak, 0);
      expect(provider.xpProgress, 0.0);
    });

    test('addXp increases xp and levels up correctly', () {
      provider.addXp(50);
      expect(provider.currentXp, 50);
      expect(provider.level, 1);

      provider.addXp(50);
      expect(provider.currentXp, 0);
      expect(provider.level, 2);
      expect(provider.nextLevelXp, 150);
    });

    test('incrementStreak increases streak by 1', () {
      provider.incrementStreak();
      expect(provider.streak, 1);
      provider.incrementStreak();
      expect(provider.streak, 2);
    });

    test('resetStreak sets streak to 0', () {
      provider.incrementStreak();
      provider.incrementStreak();
      provider.resetStreak();
      expect(provider.streak, 0);
    });

    test('setUserName updates name', () {
      provider.setUserName('María');
      expect(provider.userName, 'María');
    });

    test('notifyListeners is called on mutations', () async {
      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.addXp(10);
      provider.incrementStreak();
      await provider.setUserName('Test');

      expect(notificationCount, 3);
    });
  });
}
