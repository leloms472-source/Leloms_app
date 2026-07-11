import 'package:flutter_test/flutter_test.dart';
import 'package:leloms_app/providers/user_provider.dart';

void main() {
  late UserProvider provider;

  setUp(() {
    provider = UserProvider();
  });

  group('UserProvider', () {
    test('initial values are correct', () {
      expect(provider.userName, 'Alex');
      expect(provider.level, 1);
      expect(provider.currentXp, 0);
      expect(provider.nextLevelXp, 100);
      expect(provider.streak, 0);
      expect(provider.isLoggedIn, false);
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

    test('addXp handles multiple level ups', () {
      provider.addXp(300);
      expect(provider.level, 3);
      expect(provider.currentXp, 50);
      expect(provider.nextLevelXp, 200);
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

    test('setLoggedIn updates login state', () {
      provider.setLoggedIn(true);
      expect(provider.isLoggedIn, true);
      provider.setLoggedIn(false);
      expect(provider.isLoggedIn, false);
    });

    test('notifyListeners is called on mutations', () {
      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.addXp(10);
      provider.incrementStreak();
      provider.setUserName('Test');

      expect(notificationCount, 3);
    });
  });
}
