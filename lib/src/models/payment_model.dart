enum PaymentStatus {
  paid,
  initiated,
  failed,
  cancelled,
  timeout,
}

class Payment {
  final String id;
  final String userId;
  final String loanId;
  final double amount;
  final String status;
  final String checkoutRequestId;
  final String merchantRequestId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.loanId,
    required this.amount,
    required this.status,
    required this.checkoutRequestId,
    required this.merchantRequestId,
    required this.createdAt,
  });

  factory Payment.fromJson(String id, Map<String, dynamic> json) {
    return Payment(
      id: id,
      userId: json['userId'] ?? '',
      loanId: json['loanId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'initiated',
      checkoutRequestId: json['checkoutRequestId'] ?? '',
      merchantRequestId: json['merchantRequestId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Fallback to current time if createdAt is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'loanId': loanId,
      'amount': amount,
      'status': status,
      'checkoutRequestId': checkoutRequestId,
      'merchantRequestId': merchantRequestId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
