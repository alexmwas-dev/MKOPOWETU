import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;

  const PaymentListItem({Key? key, required this.payment}) : super(key: key);

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'initiated':
        return 'Initiated';
      case 'cancelled':
        return 'Cancelled';
      case 'timeout':
        return 'Timeout';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      case 'initiated':
        return Icons.hourglass_empty;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'timeout':
        return Icons.timer_off;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'initiated':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      case 'timeout':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_KE', symbol: 'KES');
    final dateFormat = DateFormat('MMM d, yyyy, h:mm a');
    final statusText = _getStatusText(payment.status);
    final statusIcon = _getStatusIcon(payment.status);
    final statusColor = _getStatusColor(payment.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to a details page if you have one
          context.go('/loan/payment-details', extra: payment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Loan ID: ${payment.loanId.substring(0, 6)}...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    currencyFormat.format(payment.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${dateFormat.format(payment.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
