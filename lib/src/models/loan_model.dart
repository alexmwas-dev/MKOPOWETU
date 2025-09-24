class Loan {
  final String id;
  final String uid;
  final double amount;
  final DateTime date;
  final String status;
  final int repaymentPeriod; // in days

  Loan({
    required this.id,
    required this.uid,
    required this.amount,
    required this.date,
    required this.status,
    this.repaymentPeriod = 30, // Default to 30 days
  });

  Loan copyWith({
    String? id,
    String? uid,
    double? amount,
    DateTime? date,
    String? status,
    int? repaymentPeriod,
  }) {
    return Loan(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      repaymentPeriod: repaymentPeriod ?? this.repaymentPeriod,
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      uid: json['uid'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
      repaymentPeriod: json['repaymentPeriod'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'repaymentPeriod': repaymentPeriod,
    };
  }
}
