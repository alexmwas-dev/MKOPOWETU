import 'package:firebase_database/firebase_database.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';

class PaymentService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> createPayment(String userId, Payment payment) async {
    try {
      await _dbRef.child('payments').child(userId).child(payment.id).set(payment.toJson());
    } catch (e) {
      print('Error creating payment: $e');
      rethrow;
    }
  }

  Future<List<Payment>> getPayments(String userId) async {
    try {
      final snapshot = await _dbRef.child('payments').child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          return Payment.fromJson(entry.key, Map<String, dynamic>.from(entry.value));
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }
}
