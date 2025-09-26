class Loan {
  final String id;
  final String uid;
  final double amount;
  final double interestRate;
  final double interestAmount;
  final DateTime date;
  final DateTime repaymentDate;
  final String status;

  Loan({
    required this.id,
    required this.uid,
    required this.amount,
    required this.interestRate,
    required this.interestAmount,
    required this.date,
    required this.repaymentDate,
    required this.status,
  });

  Loan copyWith({
    String? id,
    String? uid,
    double? amount,
    double? interestRate,
    double? interestAmount,
    DateTime? date,
    DateTime? repaymentDate,
    String? status,
  }) {
    return Loan(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      date: date ?? this.date,
      repaymentDate: repaymentDate ?? this.repaymentDate,
      status: status ?? this.status,
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      uid: json['uid'],
      amount: json['amount'].toDouble(),
      interestRate: json['interestRate'].toDouble(),
      interestAmount: json['interestAmount'].toDouble(),
      date: DateTime.parse(json['date']),
      repaymentDate: DateTime.parse(json['repaymentDate']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'interestRate': interestRate,
      'interestAmount': interestAmount,
      'date': date.toIso8601String(),
      'repaymentDate': repaymentDate.toIso8601String(),
      'status': status,
    };
  }
}
