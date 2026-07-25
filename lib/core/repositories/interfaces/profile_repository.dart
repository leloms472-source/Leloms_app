import '../../models/user.dart' as app;
import '../../models/academic_reputation.dart';

abstract class IProfileRepository {
  Future<app.User?> getUser(String id);
  Future<void> saveUser(app.User user);
  Future<void> updateUser(app.User user);
  Future<app.User?> getCurrentUser();
  Future<void> signOut();
  Future<AcademicReputation?> getAcademicReputation(String userId);
  Future<void> upsertAcademicReputation(AcademicReputation rep);
  Future<List<app.User>> getTopContributors({int limit = 10});
}
