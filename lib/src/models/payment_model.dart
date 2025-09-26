enum PaymentStatus {
  paid,
  initiated,
  failed,
}

class Payment {
  final String id;
  final String userId;
  final String loanId;
  final double amount;
  final PaymentStatus status;
  final String checkoutRequestId;
  final DateTime date;

  Payment({
    required this.id,
    required this.userId,
    required this.loanId,
    required this.amount,
    required this.status,
    required this.checkoutRequestId,
    required this.date,
  });

  factory Payment.fromJson(String id, Map<String, dynamic> json) {
    return Payment(
      id: id,
      userId: json['userId'] ?? '',
      loanId: json['loanId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: _getStatusFromString(json['status'] ?? 'initiated'),
      checkoutRequestId: json['checkoutRequestId'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'loanId': loanId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'checkoutRequestId': checkoutRequestId,
      'date': date.toIso8601String(),
    };
  }

  static PaymentStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.initiated;
    }
  }
}
