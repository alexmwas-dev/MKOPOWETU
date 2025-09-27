import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/services/mpesa_service.dart';
import 'package:mkopo_wetu/src/services/payment_service.dart';
import 'dart:developer' as developer;

enum PaymentStatus { idle, loading, success, failed, cancelled, timeout }

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final ConfigService _configService = ConfigService();
  MpesaService? _mpesaService;
  List<Payment> _payments = [];
  PaymentStatus _status = PaymentStatus.idle;

  List<Payment> get payments => _payments;
  PaymentStatus get status => _status;

  Future<void> _initializeMpesaService() async {
    if (_mpesaService == null) {
      try {
        final mpesaConfig = await _configService.getMpesaConfig();
        _mpesaService = MpesaService(
          consumerKey: mpesaConfig['consumerKey'],
          consumerSecret: mpesaConfig['consumerSecret'],
          passkey: mpesaConfig['passkey'],
          shortcode: mpesaConfig['shortcode'],
        );
      } catch (e, s) {
        developer.log(
          'Failed to initialize MpesaService',
          name: 'PaymentProvider',
          error: e,
          stackTrace: s,
        );
        _status = PaymentStatus.failed;
        notifyListeners();
        rethrow; // Rethrow to prevent further execution
      }
    }
  }

  Future<void> fetchPayments(String userId) async {
    _status = PaymentStatus.loading;
    notifyListeners();

    try {
      _payments = await _paymentService.getPayments(userId);
    } catch (error) {
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

    try {
      await _initializeMpesaService();

      if (_mpesaService == null) {
        throw Exception('MpesaService is not initialized');
      }

      if (loan == null && (loanAmount == null || repaymentDays == null)) {
        throw Exception('loanAmount and repaymentDays must be provided for new loans');
      }

      final checkoutRequestId = await _mpesaService!.initiateStkPush(
        amount: amount,
        phoneNumber: phoneNumber,
        accountReference: loan != null ? loan.id : 'Mkopo Wetu',
        transactionDesc: loan != null ? 'Loan Repayment' : 'Loan Application Fee',
      );

      if (loan != null) {
        await loanProvider.updateLoanPayment(loan.id, checkoutRequestId);
      } else {
        final loanId = DateTime.now().millisecondsSinceEpoch.toString();
        await loanProvider.createLoanAndPayment(
          userId: userId,
          loanId: loanId,
          amount: loanAmount!,
          interestRate: 0.2,
          interestAmount: loanAmount * 0.2,
          repaymentDate: DateTime.now().add(Duration(days: repaymentDays!)),
          checkoutRequestId: checkoutRequestId,
        );
      }

      await _pollPaymentStatus(checkoutRequestId);
    } catch (e, s) {
      developer.log(
        'Error initiating payment',
        name: 'PaymentProvider',
        error: e,
        stackTrace: s,
      );
      _status = PaymentStatus.failed;
    }

    notifyListeners();
    return _status;
  }

  Future<void> _pollPaymentStatus(String checkoutRequestId) async {
    const timeout = Duration(minutes: 2);
    final completer = Completer<void>();

    final timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final status = await _mpesaService!.checkTransactionStatus(checkoutRequestId);
        final resultCode = status['ResultCode'];

        if (resultCode == '0') {
          _status = PaymentStatus.success;
          timer.cancel();
          completer.complete();
        } else if (resultCode != '0' && status['ResultDesc'] != 'The transaction is being processed') {
          _status = PaymentStatus.failed;
          timer.cancel();
          completer.complete();
        }
      } catch (e, s) {
        developer.log(
          'Error polling payment status',
          name: 'PaymentProvider',
          error: e,
          stackTrace: s,
        );
        _status = PaymentStatus.failed;
        timer.cancel();
        completer.complete();
      }
    });

    await completer.future.timeout(timeout, onTimeout: () {
      _status = PaymentStatus.timeout;
      timer.cancel();
    });
  }

  void resetStatus() {
    _status = PaymentStatus.idle;
    notifyListeners();
  }
}
