import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';
import '../models/quiz.dart';
import '../models/flashcard.dart';
import '../models/summary.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Subjects
  Stream<List<Subject>> getSubjects() {
    return _db.collection('subjects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Subject.fromMap(doc.id, doc.data())).toList());
  }

  // Quizzes
  Stream<List<Quiz>> getQuizzes({String? subject}) {
    Query query = _db.collection('quizzes');
    if (subject != null) {
      query = query.where('subject', isEqualTo: subject);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Quiz.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  // Flashcards
  Stream<List<Flashcard>> getFlashcards({String? subject}) {
    Query query = _db.collection('flashcards');
    if (subject != null) {
      query = query.where('subject', isEqualTo: subject);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Flashcard.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  // Summaries
  Stream<List<Summary>> getSummaries() {
    return _db.collection('summaries').orderBy('votes', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Summary.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> voteSummary(String summaryId, int newVotes) async {
    await _db.collection('summaries').doc(summaryId).update({'votes': newVotes});
  }
}
