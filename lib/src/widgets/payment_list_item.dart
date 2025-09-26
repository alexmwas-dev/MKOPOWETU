import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;

  const PaymentListItem({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_KE', symbol: 'KES');
    final dateFormat = DateFormat('MMM d, yyyy, h:mm a');
    final isFailed = payment.status == PaymentStatus.failed;
    final isPaid = payment.status == PaymentStatus.paid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          context.go('/loan/payment-details', extra: payment);
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle : isFailed ? Icons.cancel : Icons.hourglass_empty,
                        color: isPaid ? Colors.green : isFailed ? Colors.red : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment ID: ${payment.id.substring(0, 6)}...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormat.format(payment.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Date: ${dateFormat.format(payment.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
