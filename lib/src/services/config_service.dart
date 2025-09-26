import 'package:firebase_database/firebase_database.dart';

class ConfigService {
  final DatabaseReference _configRef = FirebaseDatabase.instanceFor(
          app: FirebaseDatabase.instance.app,
          databaseURL: 'https://mkopo-wetu-default-rtdb.firebaseio.com/')
      .ref()
      .child('config');

  Future<double> getLoanFee() async {
    final event = await _configRef.child('loanFee').once();
    final value = event.snapshot.value;
    if (value != null) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 210.0;
      }
    }
    return 210.0; // Default value
  }

  Future<Map<String, dynamic>> getMpesaConfig() async {
    final event = await _configRef.child('mpesa').once();
    if (event.snapshot.value != null) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    }
    return {};
  }
}
