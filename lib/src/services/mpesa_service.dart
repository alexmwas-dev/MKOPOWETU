import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class MpesaService {
  final String consumerKey;
  final String consumerSecret;
  final String passkey;
  final String shortcode;

  MpesaService({
    required this.consumerKey,
    required this.consumerSecret,
    required this.passkey,
    required this.shortcode,
  });

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1);
    } else if (phoneNumber.startsWith('254')) {
      return phoneNumber;
    } else {
      return '254$phoneNumber';
    }
  }

  Future<String> _getAccessToken() async {
    final String credentials =
        base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
    final response = await http.get(
      Uri.parse(
          'https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get access token: ${response.body}');
    }
  }

  Future<String> initiateStkPush({
    required double amount,
    required String phoneNumber,
    required String accountReference,
    required String transactionDesc,
  }) async {
    final String accessToken = await _getAccessToken();
    final String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

    // Use timezone package to get Nairobi time
    tz.initializeTimeZones();
    final location = tz.getLocation('Africa/Nairobi');
    final now = tz.TZDateTime.now(location);
    final timestamp = DateFormat('yyyyMMddHHmmss').format(now);

    final String password =
        base64.encode(utf8.encode('$shortcode$passkey$timestamp'));

    final response = await http.post(
      Uri.parse('https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt(),
        'PartyA': formattedPhoneNumber,
        'PartyB': shortcode,
        'PhoneNumber': formattedPhoneNumber,
        'CallBackURL': 'https://oauth.xangbet.com/v2/transactions/verify.php',
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final checkoutRequestId = data['CheckoutRequestID'];
      if (checkoutRequestId != null) {
        return checkoutRequestId;
      } else {
        throw Exception('CheckoutRequestID not found in response.');
      }
    } else {
      throw Exception('Failed to initiate STK push: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> checkTransactionStatus(
      String checkoutRequestId) async {
    final String accessToken = await _getAccessToken();
    tz.initializeTimeZones();
    final location = tz.getLocation('Africa/Nairobi');
    final now = tz.TZDateTime.now(location);
    final timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    final String password =
        base64.encode(utf8.encode('$shortcode$passkey$timestamp'));

    final response = await http.post(
      Uri.parse('https://api.safaricom.co.ke/mpesa/stkpushquery/v1/query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check transaction status: ${response.body}');
    }
  }
}
