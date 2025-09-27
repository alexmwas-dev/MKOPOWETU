import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/services/mpesa_service.dart';
import 'package:mkopo_wetu/src/services/payment_service.dart';
import 'dart:developer' as developer;

// Enum to be returned to the UI layer
enum PaymentStatus {
  idle,
  loading,
  paid,
  failed,
  cancelled,
  timeout,
  initiated
}

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final ConfigService _configService = ConfigService();
  MpesaService? _mpesaService;
  List<Payment> _payments = [];
  // Internal state for the provider
  PaymentStatus _status = PaymentStatus.idle;
  StreamSubscription<Payment?>? _paymentStatusSubscription;

  List<Payment> get payments => _payments;
  PaymentStatus get status => _status;

  Future<void> _initializeMpesaService() async {
    if (_mpesaService != null) return;
    try {
      final mpesaConfig = await _configService.getMpesaConfig();
      _mpesaService = MpesaService(
        consumerKey: mpesaConfig['consumerKey'],
        consumerSecret: mpesaConfig['consumerSecret'],
        passkey: mpesaConfig['passkey'],
        shortcode: mpesaConfig['shortcode'],
      );
    } catch (e, s) {
      developer.log('Failed to initialize MpesaService',
          name: 'PaymentProvider', error: e, stackTrace: s);
      _status = PaymentStatus.failed;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchPayments(String userId) async {
    _status = PaymentStatus.loading;
    notifyListeners();
    try {
      // Uses getPaymentHistory to fetch all payments for a user
      _payments = await _paymentService.getPaymentHistory(userId);
    } catch (e, s) {
      developer.log('Error fetching payment history',
          name: 'PaymentProvider', error: e, stackTrace: s);
      _payments = [];
    } finally {
      _status = PaymentStatus.idle;
      notifyListeners();
    }
  }

  Future<PaymentStatus> initiatePayment({
    required double amount,
    required String phoneNumber,
    required LoanProvider loanProvider,
    required String userId,
    Loan? loan,
    double? loanAmount,
    int? repaymentDays,
  }) async {
    _status = PaymentStatus.loading;
    notifyListeners();

    final completer = Completer<PaymentStatus>();

    try {
      await _initializeMpesaService();

      final loanId =
          loan?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final checkoutRequestId = await _mpesaService!.initiateStkPush(
        amount: amount,
        phoneNumber: phoneNumber,
        accountReference: loanId,
        transactionDesc:
            loan != null ? 'Loan Repayment' : 'Loan Application Fee',
      );

      // If this is a new loan, create the records in the database
      if (loan == null) {
        await loanProvider.createLoanAndPayment(
          userId: userId,
          loanId: loanId,
          amount: loanAmount!,
          interestRate: 0.2, // Example interest
          interestAmount: loanAmount * 0.2, // Example interest amount
          repaymentDate: DateTime.now().add(Duration(days: repaymentDays!)),
          checkoutRequestId: checkoutRequestId,
        );
      }

      _status = PaymentStatus.initiated;
      notifyListeners();

      // Listen for the final status from Firebase RTDB
      _paymentStatusSubscription =
          _paymentService.getPaymentStatus(loanId).listen((payment) {
        if (payment != null && !completer.isCompleted) {
          if (payment.status == 'paid') {
            _status = PaymentStatus.paid;
            completer.complete(PaymentStatus.paid);
            _paymentStatusSubscription?.cancel();
          } else if (payment.status == 'failed') {
            _status = PaymentStatus.failed;
            completer.complete(PaymentStatus.failed);
            _paymentStatusSubscription?.cancel();
          }
          // While 'initiated', we keep listening.
          notifyListeners();
        }
      }, onError: (e, s) {
        if (!completer.isCompleted) {
          developer.log('Error in payment status stream',
              name: 'PaymentProvider', error: e, stackTrace: s);
          _status = PaymentStatus.failed;
          completer.complete(PaymentStatus.failed);
          notifyListeners();
        }
      });

      // Timeout logic in case no final status is received
      Future.delayed(const Duration(seconds: 90), () {
        if (!completer.isCompleted) {
          _paymentStatusSubscription?.cancel();
          _status = PaymentStatus.timeout;
          notifyListeners();
          completer.complete(PaymentStatus.timeout);
        }
      });
    } catch (e, s) {
      developer.log('Error initiating payment',
          name: 'PaymentProvider', error: e, stackTrace: s);
      _status = PaymentStatus.failed;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete(PaymentStatus.failed);
      }
    }
    // Return the future that will complete with the final status
    return completer.future;
  }

  void resetStatus() {
    _status = PaymentStatus.idle;
    _paymentStatusSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentStatusSubscription?.cancel();
    super.dispose();
  }
}
