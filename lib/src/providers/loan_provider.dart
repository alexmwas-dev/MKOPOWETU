import 'dart:async';
import 'package:flutter/material.dart';
import 'package:okoa_loan/src/models/loan_model.dart';
import 'package:okoa_loan/src/services/loan_service.dart';

class LoanProvider with ChangeNotifier {
  final LoanService _loanService = LoanService();
  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _error;

  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> applyForLoan(String userId, double amount) async {
    _setLoading(true);
    _setError(null);

    try {
      final existingLoans = await _loanService.getLoans(userId);

      if (existingLoans.any((loan) => loan.status == 'pending')) {
        throw Exception('You already have a pending loan application.');
      }

      final rejectedLoans = existingLoans.where((loan) => loan.status == 'rejected').toList();
      if (rejectedLoans.isNotEmpty) {
        final lastRejectedLoan = rejectedLoans.last;
        final difference = DateTime.now().difference(lastRejectedLoan.date);
        if (difference.inDays < 3) {
          final daysRemaining = 3 - difference.inDays;
          throw Exception('You cannot apply for a new loan for another $daysRemaining day(s) after a rejection.');
        }
      }

      final loan = Loan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: userId,
        amount: amount,
        date: DateTime.now(),
        status: 'pending',
      );

      await _loanService.createLoan(loan);
      _loans.insert(0, loan);
      notifyListeners();

      // Simulate automatic rejection after 30 seconds
      Timer(const Duration(seconds: 30), () async {
        final currentLoan = _loans.firstWhere((l) => l.id == loan.id, orElse: () => loan);
        if (currentLoan.status == 'pending') {
          await updateLoanStatus(loan.id, 'rejected');
        }
      });

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLoans(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _loans = await _loanService.getLoans(userId);
      _loans.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLoanStatus(String loanId, String status) async {
    try {
      await _loanService.updateLoanStatus(loanId, status);
      final index = _loans.indexWhere((loan) => loan.id == loanId);
      if (index != -1) {
        _loans[index] = _loans[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> repayLoan(String loanId, double amount) async {
    _setLoading(true);
    _setError(null);

    try {
      final loanToRepay = _loans.firstWhere((loan) => loan.id == loanId);
      final remainingAmount = loanToRepay.amount - amount;

      if (remainingAmount < 0) {
        throw Exception('Repayment amount cannot be greater than the loan amount.');
      }

      if (remainingAmount == 0) {
        await updateLoanStatus(loanId, 'paid');
      } else {
        // Here you would typically update the loan amount in your backend
        // For this example, we'll just update the local copy
        final index = _loans.indexWhere((loan) => loan.id == loanId);
        if (index != -1) {
          _loans[index] = _loans[index].copyWith(amount: remainingAmount);
          notifyListeners();
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
