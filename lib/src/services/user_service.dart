import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _usersRef = FirebaseDatabase.instanceFor(
          app: FirebaseDatabase.instance.app,
          databaseURL: 'https://mkopo-wetu-default-rtdb.firebaseio.com/')
      .ref()
      .child('users');

  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _usersRef.child(uid).set(userData);
  }

  Future<DataSnapshot> getUser(String uid) async {
    return await _usersRef.child(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.child(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _usersRef.child(uid).remove();
  }
}
