import '../../models/career.dart';
import '../../models/subject.dart';
import '../../models/topic.dart';

abstract class ICareerRepository {
  Future<List<Career>> getCareers();
  Future<List<Subject>> getSubjects(String careerId);
  Future<List<Topic>> getTopics(String subjectId);
}
