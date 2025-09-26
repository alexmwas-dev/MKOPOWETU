import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/services/loan_service.dart';
import 'package:mkopo_wetu/src/services/payment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoanProvider with ChangeNotifier {
  final LoanService _loanService = LoanService();
  final PaymentService _paymentService = PaymentService();
  final ConfigService _configService = ConfigService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Loan> _loans = [];
  List<Payment> _payments = [];

  List<Loan> get loans => _loans;
  List<Payment> get payments => _payments;

  Future<void> fetchLoans() async {
    final user = _auth.currentUser;
    if (user != null) {
      _loans = await _loanService.getLoans(user.uid);
      _loans.sort((a, b) => b.date.compareTo(a.date)); // Sort by most recent
      notifyListeners();
    }
  }

  Future<void> fetchPayments() async {
    final user = _auth.currentUser;
    if (user != null) {
      _payments = await _paymentService.getPayments(user.uid);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> isEligibleForLoan() async {
    if (_loans.any((loan) => loan.status == 'pending')) {
      return {'eligible': false, 'message': 'You already have a pending loan application.'};
    }

    final rejectedLoans = _loans.where((loan) => loan.status == 'rejected').toList();
    if (rejectedLoans.isNotEmpty) {
      final lastRejectedLoan = rejectedLoans.first; // Already sorted
      final difference = DateTime.now().difference(lastRejectedLoan.date);
      if (difference.inDays < 3) {
        final daysRemaining = 3 - difference.inDays;
        return {
          'eligible': false,
          'message': 'You can try applying for a loan after $daysRemaining day(s).'
        };
      }
    }

    return {'eligible': true};
  }

  Future<void> updateLoanStatus(String loanId, String status) async {
    try {
      await _loanService.updateLoanStatus(loanId, status);
      await fetchLoans(); // Refresh loans after updating status
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLoanPayment(String loanId, String checkoutRequestId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final loanFee = await _configService.getLoanFee();
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        loanId: loanId,
        amount: loanFee,
        status: PaymentStatus.initiated,
        checkoutRequestId: checkoutRequestId,
        date: DateTime.now(),
      );
      await _paymentService.createPayment(user.uid, payment);
      await fetchPayments();

      Timer(const Duration(minutes: 2), () async {
        await fetchLoans();
        final currentLoan = _loans.firstWhere((l) => l.id == loanId);
        if (currentLoan.status == 'on-hold') {
          await updateLoanStatus(loanId, 'rejected');
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createLoanAndPayment({
    required String userId,
    required String loanId,
    required double amount,
    required double interestRate,
    required double interestAmount,
    required DateTime repaymentDate,
    required String checkoutRequestId,
  }) async {
    try {
      final eligibility = await isEligibleForLoan();
      if (!eligibility['eligible']) {
        throw Exception(eligibility['message']);
      }

      final loan = Loan(
        id: loanId,
        uid: userId,
        amount: amount,
        interestRate: interestRate,
        interestAmount: interestAmount,
        repaymentDate: repaymentDate,
        date: DateTime.now(),
        status: 'on-hold',
      );
      await _loanService.createLoan(loan);

      final loanFee = await _configService.getLoanFee();
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        loanId: loanId,
        amount: loanFee,
        status: PaymentStatus.initiated,
        checkoutRequestId: checkoutRequestId,
        date: DateTime.now(),
      );
      await _paymentService.createPayment(userId, payment);
      
      await fetchLoans();
      await fetchPayments();

      Timer(const Duration(minutes: 2), () async {
        await fetchLoans();
        final currentLoan = _loans.firstWhere((l) => l.id == loan.id);
        if (currentLoan.status == 'on-hold') {
          await updateLoanStatus(loan.id, 'rejected');
        }
      });

    } catch (e) {
      rethrow;
    }
  }
}
