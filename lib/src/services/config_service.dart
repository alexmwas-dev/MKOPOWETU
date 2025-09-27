import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;

class ConfigService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<double> getLoanFee() async {
    try {
      final snapshot = await _database.ref('config/loanFee').get();
      if (snapshot.exists) {
        final fee = snapshot.value;
        if (fee is num) {
          return fee.toDouble();
        } else if (fee is String) {
          final sanitizedFee = fee.replaceAll(RegExp(r'[^0-9.]'), '');
          final parsedFee = double.tryParse(sanitizedFee);
          if (parsedFee != null) {
            return parsedFee;
          }
        }
      }
      throw Exception('Loan fee not found or in incorrect format');
    } catch (e, s) {
      developer.log(
        'Error fetching loan fee',
        name: 'ConfigService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMpesaConfig() async {
    try {
      final snapshot = await _database.ref('config/mpesa').get();
      if (snapshot.exists && snapshot.value is Map) {
        // The value from RTDB can be Map<dynamic, dynamic>, so we need to cast it.
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      }
      throw Exception('Mpesa config not found or in incorrect format');
    } catch (e, s) {
      developer.log(
        'Error fetching Mpesa config',
        name: 'ConfigService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
