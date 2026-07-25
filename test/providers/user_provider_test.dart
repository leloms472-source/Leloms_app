import 'package:flutter_test/flutter_test.dart';
import 'package:leloms_app/providers/profile_provider.dart';
import 'package:leloms_app/core/models/user.dart';

void main() {
  late ProfileProvider provider;

  setUp(() {
    provider = ProfileProvider();
  });

  group('ProfileProvider', () {
    test('initial values are correct', () {
      expect(provider.userName, 'Estudiante');
      expect(provider.user, isNull);
      expect(provider.isInitialized, false);
    });

    test('setUser updates state', () {
      final user = User(id: '1', fullName: 'María', username: 'maria');
      provider.setUser(user);
      expect(provider.userName, 'María');
      expect(provider.user?.id, '1');
    });

    test('signOut clears user', () {
      final user = User(id: '1', fullName: 'Test', username: 'test');
      provider.setUser(user);
      expect(provider.user, isNotNull);

      provider.signOut();
      expect(provider.user, isNull);
      expect(provider.userName, 'Estudiante');
    });

    test('initialize sets isInitialized', () async {
      expect(provider.isInitialized, false);
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('userName falls back to Estudiante', () {
      final user = User(id: '1', fullName: '', username: '');
      provider.setUser(user);
      expect(provider.userName, 'Estudiante');
    });
  });
}
