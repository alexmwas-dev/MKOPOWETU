import 'package:firebase_database/firebase_database.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';

class LoanService {
  final DatabaseReference _loansRef = FirebaseDatabase.instanceFor(
          app: FirebaseDatabase.instance.app,
          databaseURL: 'https://mkopo-wetu-default-rtdb.firebaseio.com/')
      .ref()
      .child('loans');

  Future<void> createLoan(Loan loan) async {
    final newLoanRef = _loansRef.push();
    await newLoanRef.set({
      'id': newLoanRef.key,
      'uid': loan.uid,
      'amount': loan.amount,
      'date': loan.date.toIso8601String(),
      'status': loan.status,
      'interestRate': loan.interestRate,
      'interestAmount': loan.interestAmount,
      'repaymentDate': loan.repaymentDate.toIso8601String(),
    });
  }

  Future<List<Loan>> getLoans(String userId) async {
    final event = await _loansRef.orderByChild('uid').equalTo(userId).once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        final loanData = e.value as Map<dynamic, dynamic>;
        return Loan(
          id: loanData['id'],
          uid: loanData['uid'],
          amount: loanData['amount'] is int
              ? (loanData['amount'] as int).toDouble()
              : loanData['amount'],
          date: DateTime.parse(loanData['date']),
          status: loanData['status'],
          interestRate: loanData['interestRate'] is int
              ? (loanData['interestRate'] as int).toDouble()
              : loanData['interestRate'],
          interestAmount: loanData['interestAmount'] is int
              ? (loanData['interestAmount'] as int).toDouble()
              : loanData['interestAmount'],
          repaymentDate: DateTime.parse(loanData['repaymentDate']),
        );
      }).toList();
    }
    return [];
  }

  Future<void> updateLoanStatus(String loanId, String status) async {
    final event = await _loansRef.orderByChild('id').equalTo(loanId).once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final loanKey = data.keys.first;
      await _loansRef.child(loanKey).update({'status': status});
    }
  }
}
