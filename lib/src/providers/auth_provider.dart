import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/user_model.dart';
import 'package:mkopo_wetu/src/services/user_service.dart';
import 'package:mkopo_wetu/src/services/otp_service.dart';

class AuthProvider with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final UserService _userService = UserService();
  auth.User? _firebaseUser;
  User? _user;

  auth.User? get firebaseUser => _firebaseUser;
  User? get user => _user;

  bool get isAuthenticated => _firebaseUser != null && _user != null;
  bool get isVerified => _user?.isVerified ?? false;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  String _sanitizePhoneNumber(String phone) => phone.replaceAll(RegExp(r'[^\d]+'), '');

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    developer.log('AuthState changed. Firebase user: ${firebaseUser?.uid}', name: 'AuthProvider.onAuthStateChanged');
    if (firebaseUser == null) {
      _firebaseUser = null;
      _user = null;
      developer.log('User is logged out.', name: 'AuthProvider.onAuthStateChanged');
    } else {
      _firebaseUser = firebaseUser;
      developer.log('User is logged in. Fetching user data...', name: 'AuthProvider.onAuthStateChanged');
      final userDoc = await _userService.getUser(firebaseUser.uid);
      if (userDoc.exists) {
        _user = User.fromJson(_convertObjectMapToStringMap(userDoc.value));
        developer.log('User data loaded successfully: ${_user?.toJson()}', name: 'AuthProvider.onAuthStateChanged');
      } else {
        _user = null;
        developer.log('User data not found in database.', name: 'AuthProvider.onAuthStateChanged');
      }
    }
    notifyListeners();
  }

  Future<void> loginWithPhoneNumber(String phoneNumber, String password) async {
    try {
      final email = '${_sanitizePhoneNumber(phoneNumber)}@mkopowetu.com';
      developer.log('Attempting to log in with email: $email', name: 'AuthProvider.login');
      final userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _onAuthStateChanged(userCredential.user);
      developer.log('Login successful for user: ${userCredential.user?.uid}', name: 'AuthProvider.login');
    } on auth.FirebaseAuthException catch (e, s) {
      developer.log('Login failed', name: 'AuthProvider.login', error: e, stackTrace: s);
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWithPhone(String phoneNumber, String password) async {
    try {
      final email = '${_sanitizePhoneNumber(phoneNumber)}@mkopowetu.com';
      developer.log('Attempting to register with email: $email', name: 'AuthProvider.register');
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final newUser = User(
          uid: firebaseUser.uid,
          phoneNumber: phoneNumber,
          email: email,
          isVerified: false,
        );
        await _userService.createUser(firebaseUser.uid, newUser.toJson());
        await OtpService.sendOtp(firebaseUser.uid, phoneNumber);
        _firebaseUser = firebaseUser;
        _user = newUser;
        notifyListeners();
        developer.log('Registration successful for user: ${firebaseUser.uid}', name: 'AuthProvider.register');
      }
    } on auth.FirebaseAuthException catch (e, s) {
      developer.log('Registration failed', name: 'AuthProvider.register', error: e, stackTrace: s);
      throw _handleAuthException(e);
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_firebaseUser == null) {
      developer.log('OTP verification failed: User not logged in.', name: 'AuthProvider.verifyOtp');
      throw Exception('No user logged in to verify OTP.');
    }
    developer.log('Verifying OTP for user: ${_firebaseUser!.uid}', name: 'AuthProvider.verifyOtp');
    final isVerified = await OtpService.verifyOtp(_firebaseUser!.uid, otp);
    if (isVerified) {
      developer.log('OTP verification successful.', name: 'AuthProvider.verifyOtp');
      _user = _user?.copyWith(isVerified: true);
      await updateUserDetails({'isVerified': true});
    } else {
      developer.log('OTP verification failed: Invalid OTP.', name: 'AuthProvider.verifyOtp');
    }
    return isVerified;
  }

  Future<void> resendOtp() async {
    if (_firebaseUser != null && _user != null) {
      developer.log('Resending OTP to ${_user!.phoneNumber}', name: 'AuthProvider.resendOtp');
      await OtpService.sendOtp(_firebaseUser!.uid, _user!.phoneNumber);
    } else {
      developer.log('Resend OTP failed: User not logged in.', name: 'AuthProvider.resendOtp');
      throw Exception('User not logged in, cannot resend OTP.');
    }
  }

  Future<void> updateUserDetails(Map<String, dynamic> details) async {
    if (_firebaseUser != null) {
      try {
        developer.log('Updating user details for ${_firebaseUser!.uid}: $details', name: 'AuthProvider.updateUserDetails');
        await _userService.updateUser(_firebaseUser!.uid, details);
        final userDoc = await _userService.getUser(_firebaseUser!.uid);
        if (userDoc.exists) {
          _user = User.fromJson(_convertObjectMapToStringMap(userDoc.value));
          notifyListeners();
          developer.log('User details updated successfully.', name: 'AuthProvider.updateUserDetails');
        }
      } catch (e, s) {
        developer.log('Failed to update user details', name: 'AuthProvider.updateUserDetails', error: e, stackTrace: s);
        throw Exception('Failed to update user details: $e');
      }
    }
  }

  Future<void> updatePersonalInfo(
    String name,
    String email,
    String idNumber,
    String dob,
    String gender,
    String maritalStatus,
  ) async {
    await updateUserDetails({
      'name': name,
      'email': email,
      'idNumber': idNumber,
      'dob': dob,
      'gender': gender,
      'maritalStatus': maritalStatus,
    });
  }

  Future<void> updateFinancialInfo(
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

  Future<void> updateUser({
    bool? isConsentComplete,
  }) async {
    Map<String, dynamic> details = {};
    if (isConsentComplete != null) {
      details['isConsentComplete'] = isConsentComplete;
    }

    if (details.isNotEmpty) {
      await updateUserDetails(details);
    }
  }

  Future<void> logout() async {
    developer.log('User logging out.', name: 'AuthProvider.logout');
    await _auth.signOut();
  }

  Exception _handleAuthException(auth.FirebaseAuthException e) {
    developer.log('Auth Exception: ${e.code}', name: 'AuthProvider.handleAuthException', error: e);
    switch (e.code) {
      case 'invalid-email':
        return Exception('The phone number format is not valid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'user-not-found':
        return Exception('No user found for that phone number.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('This phone number is already in use by another account.');
      case 'operation-not-allowed':
        return Exception('Registration is currently disabled. Please enable Email/Password sign-in in your Firebase console.');
      case 'weak-password':
        return Exception('The password is too weak.');
      default:
        return Exception('An unknown authentication error occurred: ${e.code}');
    }
  }

  Map<String, dynamic> _convertObjectMapToStringMap(Object? data) {
  if (data == null) {
    return {};
  }

  Map<String, dynamic> newMap = {};
  (data as Map<Object?, Object?>).forEach((key, value) {
    if (value is Map<Object?, Object?>) {
      newMap[key.toString()] = _convertObjectMapToStringMap(value);
    } else {
      newMap[key.toString()] = value;
    }
  });

  return newMap;
}
}
