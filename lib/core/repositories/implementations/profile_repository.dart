import '../../services/interfaces/supabase_service.dart';
import '../../models/user.dart' as app;
import '../../models/academic_reputation.dart';
import '../interfaces/profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ISupabaseService _supabase;

  ProfileRepository(this._supabase);

  @override
  Future<app.User?> getUser(String id) => _supabase.fetchUser(id);

  @override
  Future<void> saveUser(app.User user) => _supabase.upsertUser(user);

  @override
  Future<void> updateUser(app.User user) => _supabase.upsertUser(user);

  @override
  Future<app.User?> getCurrentUser() async {
    final id = _supabase.currentUserId;
    if (id == null) return null;
    return _supabase.fetchUser(id);
  }

  @override
  Future<void> signOut() => _supabase.signOut();

  @override
  Future<AcademicReputation?> getAcademicReputation(String userId) => _supabase.fetchAcademicReputation(userId);

  @override
  Future<void> upsertAcademicReputation(AcademicReputation rep) => _supabase.upsertAcademicReputation(rep);

  @override
  Future<List<app.User>> getTopContributors({int limit = 10}) => _supabase.fetchTopContributors(limit: limit);
}
