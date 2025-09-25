import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:mkopo_wetu/src/services/user_service.dart';

class OtpService {
  static const String _baseUrl = 'https://api.mobilesasa.com/v1/send/message';
  static const String _apiToken =
      'Jdgk5eJ9nuYmXa6fzRCrmgmMrHgS4fZHFcANYC9dY80cGixkHW3mLKXUFKcx';
  static final UserService _userService = UserService();

  static Future<void> sendOtp(String uid, String phoneNumber) async {
    final otp = generateOtp();
    final message = '[Mkopo Wetu] Your verification code is: $otp';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: json.encode({
          'senderID': 'KENCHAMWA',
          'message': message,
          'phone': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        await _userService.updateUser(uid, {'otp': otp});
      } else {
        print('Failed to send OTP SMS: ${response.body}');
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      print('Failed to send OTP: $e');
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  static Future<bool> verifyOtp(String uid, String otp) async {
    try {
      final userDoc = await _userService.getUser(uid);
      if (!userDoc.exists) {
        print('User not found during OTP verification.');
        return false;
      }
      final userData = _convertObjectMapToStringMap(userDoc.value);
      final savedOtp = userData['otp'];

      if (savedOtp != null && savedOtp == otp) {
        await _userService.updateUser(uid, {'otp': null});
        print('OTP verified!');
        return true;
      } else {
        print('Invalid OTP');
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  static String generateOtp() {
    var rnd = Random();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  static Map<String, dynamic> _convertObjectMapToStringMap(Object? data) {
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
