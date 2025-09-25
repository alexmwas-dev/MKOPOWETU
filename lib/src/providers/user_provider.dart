import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/user_model.dart';
import 'package:mkopo_wetu/src/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  User? _user;

  User? get user => _user;

  UserProvider(this._userService);

  Future<void> fetchUser(String uid) async {
    final userDoc = await _userService.getUser(uid);
    if (userDoc.exists) {
      _user = User.fromJson(userDoc.value as Map<String, dynamic>);
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _userService.updateUser(uid, data);
    await fetchUser(uid);
  }
}
