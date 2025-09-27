import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/services/mpesa_service.dart';
import 'package:mkopo_wetu/src/services/payment_service.dart';
import 'dart:developer' as developer;

// Enum to be returned to the UI layer
enum PaymentStatusUI {
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
  PaymentStatusUI _status = PaymentStatusUI.idle;
  StreamSubscription<Payment?>? _paymentStatusSubscription;

  List<Payment> get payments => _payments;
  PaymentStatusUI get status => _status;

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
      _status = PaymentStatusUI.failed;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchPayments(String userId) async {
    _status = PaymentStatusUI.loading;
    notifyListeners();
    try {
      _payments = await _paymentService.getPaymentHistory(userId);
    } catch (e, s) {
      developer.log('Error fetching payment history',
          name: 'PaymentProvider', error: e, stackTrace: s);
      _payments = [];
    } finally {
      _status = PaymentStatusUI.idle;
      notifyListeners();
    }
  }

  Future<PaymentStatusUI> initiatePayment({
    required double amount,
    required String phoneNumber,
    required LoanProvider loanProvider,
    required String userId,
    required String loanId,
    double? loanAmount,
    int? repaymentDays,
    required double interestRate,
  }) async {
    _status = PaymentStatusUI.loading;
    notifyListeners();

    final completer = Completer<PaymentStatusUI>();

    try {
      await _initializeMpesaService();

      final checkoutRequestId = await _mpesaService!.initiateStkPush(
        amount: amount,
        phoneNumber: phoneNumber,
        accountReference: loanId,
        transactionDesc:
            loanAmount != null ? 'Loan Application Fee' : 'Loan Repayment',
      );

      final merchantRequestId = checkoutRequestId;

      if (loanAmount != null && repaymentDays != null) {
        await loanProvider.createLoanAndPayment(
          userId: userId,
          loanId: loanId,
          amount: loanAmount,
          interestRate: interestRate, // Correct interest rate
          interestAmount: loanAmount * interestRate * repaymentDays, // Correct interest amount
          repaymentDate: DateTime.now().add(Duration(days: repaymentDays)),
          checkoutRequestId: checkoutRequestId, // Save the correct ID
          merchantRequestId: merchantRequestId,
        );
      } else {
        await _paymentService.createPayment(
          payment: Payment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            loanId: loanId,
            userId: userId,
            amount: amount,
            status: 'initiated',
            checkoutRequestId: checkoutRequestId,
            merchantRequestId: merchantRequestId,
            createdAt: DateTime.now(),
          ),
        );
      }

      _status = PaymentStatusUI.initiated;
      notifyListeners();

      _paymentStatusSubscription = _paymentService
          .getPaymentStatusByMerchantId(merchantRequestId)
          .listen((payment) {
        if (payment != null && !completer.isCompleted) {
          final paymentStatus = _getPaymentStatusFromString(payment.status);

          if (paymentStatus != PaymentStatusUI.initiated &&
              paymentStatus != PaymentStatusUI.loading) {
            _status = paymentStatus;
            completer.complete(paymentStatus);
            _paymentStatusSubscription?.cancel();
          }
          notifyListeners();
        }
      }, onError: (e, s) {
        if (!completer.isCompleted) {
          developer.log('Error in payment status stream',
              name: 'PaymentProvider', error: e, stackTrace: s);
          _status = PaymentStatusUI.failed;
          completer.complete(PaymentStatusUI.failed);
          notifyListeners();
        }
      });

      Future.delayed(const Duration(seconds: 120), () {
        if (!completer.isCompleted) {
          _paymentStatusSubscription?.cancel();
          _status = PaymentStatusUI.timeout;
          notifyListeners();
          completer.complete(PaymentStatusUI.timeout);
          _paymentService.updatePaymentStatusByMerchantId(
              merchantRequestId, 'timeout');
        }
      });
    } catch (e, s) {
      developer.log('Error initiating payment',
          name: 'PaymentProvider', error: e, stackTrace: s);
      _status = PaymentStatusUI.failed;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete(PaymentStatusUI.failed);
      }
    }
    return completer.future;
  }

  PaymentStatusUI _getPaymentStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatusUI.paid;
      case 'failed':
        return PaymentStatusUI.failed;
      case 'cancelled':
        return PaymentStatusUI.cancelled;
      case 'timeout':
        return PaymentStatusUI.timeout;
      default:
        return PaymentStatusUI.initiated;
    }
  }

  void resetStatus() {
    _status = PaymentStatusUI.idle;
    _paymentStatusSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentStatusSubscription?.cancel();
    super.dispose();
  }
}
