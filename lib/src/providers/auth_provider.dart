import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:okoa_loan/src/models/user_model.dart';
import 'package:okoa_loan/src/services/user_service.dart';
import 'package:okoa_loan/src/services/otp_service.dart';

class AuthProvider with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final UserService _userService = UserService();
  auth.User? _firebaseUser;
  User? _user;

  auth.User? get firebaseUser => _firebaseUser;
  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((firebaseUser) async {
      await _onAuthStateChanged(firebaseUser);
    });
  }

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _firebaseUser = null;
      _user = null;
    } else {
      _firebaseUser = firebaseUser;
      final userDoc = await _userService.getUser(firebaseUser.uid);
      if (userDoc.exists) {
        _user = User.fromJson(userDoc.value as Map<String, dynamic>);
      } else {
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> loginWithPhoneNumber(String phoneNumber, String password) async {
    try {
      final email = '$phoneNumber@okoaloan.com';
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWithEmail(String email, String password, String phoneNumber) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final newUser = User(
          uid: userCredential.user!.uid,
          email: email,
          phoneNumber: phoneNumber,
        );
        await _userService.createUser(userCredential.user!.uid, newUser.toJson());
        await _onAuthStateChanged(userCredential.user);
      }
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWithPhone(String phoneNumber, String password) async {
    try {
      final email = '$phoneNumber@okoaloan.com';
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final newUser = User(
          uid: userCredential.user!.uid,
          phoneNumber: phoneNumber,
          email: email,
        );
        await _userService.createUser(userCredential.user!.uid, newUser.toJson());
        await OtpService.sendOtp(userCredential.user!.uid, phoneNumber);
        await _onAuthStateChanged(userCredential.user);
      }
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_firebaseUser == null) {
      throw Exception('No user logged in to verify OTP.');
    }
    final isVerified = await OtpService.verifyOtp(_firebaseUser!.uid, otp);
    if (isVerified) {
      await updateUserDetails({'isVerified': true});
    }
    return isVerified;
  }

  Future<void> resendOtp() async {
    if (_firebaseUser != null && _user != null) {
      await OtpService.sendOtp(_firebaseUser!.uid, _user!.phoneNumber);
    } else {
      throw Exception('User not logged in, cannot resend OTP.');
    }
  }

  Future<void> updateUserDetails(Map<String, dynamic> details) async {
    if (_firebaseUser != null) {
      try {
        await _userService.updateUser(_firebaseUser!.uid, details);
        final userDoc = await _userService.getUser(_firebaseUser!.uid);
        _user = User.fromJson(userDoc.value as Map<String, dynamic>);
        notifyListeners();
      } catch (e) {
        throw Exception('Failed to update user details: $e');
      }
    }
  }

  Future<void> updatePersonalInfo(
    String name,
    String idNumber,
    String dob,
    String gender,
    String maritalStatus,
  ) async {
    await updateUserDetails({
      'name': name,
      'idNumber': idNumber,
      'dob': dob,
      'gender': gender,
      'maritalStatus': maritalStatus,
    });
  }

  Future<void> updateBasicInfo(
    String county,
    String city,
    String address,
  ) async {
    await updateUserDetails({
      'county': county,
      'city': city,
      'address': address,
    });
  }

  Future<void> updatePersonalDetails(
    String firstName,
    String lastName,
    String nationalId,
    String phoneNumber,
  ) async {
    await updateUserDetails({
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
    });
  }

  Future<void> updateFinancialDetails(
    String employmentStatus,
    double monthlyIncome,
    double monthlyExpenses,
  ) async {
    await updateUserDetails({
      'employmentStatus': employmentStatus,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    if (_firebaseUser != null) {
      try {
        await _userService.deleteUser(_firebaseUser!.uid);
        await _firebaseUser!.delete();
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception(
              'This operation is sensitive and requires recent authentication. Please log out and log back in to delete your account.');
        }
        throw _handleAuthException(e);
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
    }
  }

  Exception _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-disabled':
        return Exception('This user has been disabled.');
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      case 'email-already-in-use':
        return Exception('The email address is already in use by another account.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'weak-password':
        return Exception('The password is too weak.');
      default:
        return Exception('An unknown authentication error occurred.');
    }
  }
}
