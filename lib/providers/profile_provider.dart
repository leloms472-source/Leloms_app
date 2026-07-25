import 'package:flutter/foundation.dart';
import '../core/models/user.dart';

class ProfileProvider extends ChangeNotifier {
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  String get userName => _user?.fullName.isNotEmpty == true ? _user!.fullName : _user?.username ?? 'Estudiante';
  String? get userCareer => _user?.careerId;
  String? get avatarUrl => _user?.avatarUrl;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}
