import 'package:firebase_database/firebase_database.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'dart:developer' as developer;

class PaymentService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> createPayment(String userId, Payment payment) async {
    try {
      await _dbRef
          .child('payments')
          .child(payment.loanId)
          .set(payment.toJson());
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

  Future<List<Payment>> getPaymentHistory(String userId) async {
    try {
      final snapshot = await _dbRef
          .child('payments')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((entry) {
              if (entry.value is Map) {
                return Payment.fromJson(
                    entry.key, Map<String, dynamic>.from(entry.value));
              } else {
                return null;
              }
            })
            .where((payment) => payment != null)
            .cast<Payment>()
            .toList();
      }
      return [];
    } catch (e, s) {
      developer.log(
        'Error fetching payment history',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Stream<Payment?> getPaymentStatus(String loanId) {
    return _dbRef.child('payments').child(loanId).onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        return Payment.fromJson(event.snapshot.key!,
            Map<String, dynamic>.from(event.snapshot.value as Map));
      }
      return null;
    }).handleError((e, s) {
      developer.log(
        'Error in payment status stream for loanId: $loanId',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
    });
  }
}
