import '../../services/interfaces/supabase_service.dart';
import '../../models/career.dart';
import '../../models/subject.dart';
import '../../models/topic.dart';
import '../interfaces/career_repository.dart';

class CareerRepository implements ICareerRepository {
  final ISupabaseService _supabase;

  CareerRepository(this._supabase);

  @override
  Future<List<Career>> getCareers() => _supabase.fetchCareers();

  @override
  Future<List<Subject>> getSubjects(String careerId) => _supabase.fetchSubjects(careerId);

  @override
  Future<List<Topic>> getTopics(String subjectId) => _supabase.fetchTopics(subjectId);
}
