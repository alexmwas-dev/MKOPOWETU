import 'package:firebase_database/firebase_database.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'dart:developer' as developer;

class PaymentService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> createPayment(String userId, Payment payment) async {
    try {
      await _dbRef.child('payments').child(userId).child(payment.id).set(payment.toJson());
    } catch (e, s) {
      developer.log(
        'Error creating payment',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<Payment>> getPayments(String userId) async {
    try {
      final snapshot = await _dbRef.child('payments').child(userId).get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        return data.entries.map((entry) {
          if (entry.value is Map) {
            return Payment.fromJson(entry.key, Map<String, dynamic>.from(entry.value));
          } else {
            developer.log(
              'Invalid payment data format for key: ${entry.key}',
              name: 'PaymentService',
              level: 900, // Warning
            );
            return null;
          }
        }).where((payment) => payment != null).cast<Payment>().toList();
      }
      return [];
    } catch (e, s) {
      developer.log(
        'Error fetching payments',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }
}
