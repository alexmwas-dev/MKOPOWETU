import 'package:firebase_database/firebase_database.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'dart:developer' as developer;

class PaymentService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> createPayment({required Payment payment}) async {
    try {
      // Use a unique ID for each payment record to allow for multiple payments per loan
      await _dbRef.child('payments').child(payment.id).set(payment.toJson());
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

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final paymentData = Map<String, dynamic>.from(entry.value);
          return Payment.fromJson(
              entry.key, paymentData);
        }).toList();
      }
      return [];
    } catch (e, s) {
      developer.log(
        'Error fetching payment history for user: $userId',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Stream<Payment?> getPaymentStatusByMerchantId(String merchantRequestId) {
    return _dbRef
        .child('payments')
        .orderByChild('merchantRequestId')
        .equalTo(merchantRequestId)
        .onValue
        .map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final firstKey = data.keys.first;
        return Payment.fromJson(
            firstKey, Map<String, dynamic>.from(data[firstKey]));
      }
      return null;
    }).handleError((e, s) {
      developer.log(
        'Error in payment status stream for merchantId: $merchantRequestId',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
    });
  }

  Future<void> updatePaymentStatusByMerchantId(
      String merchantRequestId, String newStatus) async {
    try {
      final snapshot = await _dbRef
          .child('payments')
          .orderByChild('merchantRequestId')
          .equalTo(merchantRequestId)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final paymentKey = data.keys.first;
        await _dbRef
            .child('payments')
            .child(paymentKey)
            .update({'status': newStatus});
      }
    } catch (e, s) {
      developer.log(
        'Error updating payment status for merchantId: $merchantRequestId',
        name: 'PaymentService',
        error: e,
        stackTrace: s,
      );
    }
  }
}
