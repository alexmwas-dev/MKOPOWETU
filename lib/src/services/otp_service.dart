import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:okoa_loan/src/services/user_service.dart';

class OtpService {
  static const String _baseUrl = 'https://api.mobilesasa.com/v1/send/message';
  static const String _apiToken = 'Jdgk5eJ9nuYmXa6fzRCrmgmMrHgS4fZHFcANYC9dY80cGixkHW3mLKXUFKcx';
  static final UserService _userService = UserService();

  static Future<void> sendOtp(String uid, String phoneNumber) async {
    final otp = generateOtp();
    final message = '[Okoa Loan] Your verification code is: $otp';

    try {
      await _userService.updateUser(uid, {'otp': otp});
    } catch (e) {
      print('Failed to save OTP: $e');
      throw Exception('Failed to prepare OTP. Please try again.');
    }

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

    if (response.statusCode != 200) {
      print('Failed to send OTP SMS: ${response.body}');
      throw Exception('Failed to send OTP');
    }
  }

  static Future<bool> verifyOtp(String uid, String otp) async {
    try {
      final userDoc = await _userService.getUser(uid);
      if (!userDoc.exists) {
        print('User not found during OTP verification.');
        return false;
      }
      final userData = userDoc.value as Map<String, dynamic>;
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
}
