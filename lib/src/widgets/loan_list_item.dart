import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';

class LoanListItem extends StatelessWidget {
  final Loan loan;

  const LoanListItem({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_KE', symbol: 'KES ');
    final dateFormat = DateFormat('MMM d, yyyy');
    // Use NumberFormat for robust percentage formatting
    final percentFormat = NumberFormat('0.0#%');
    final totalRepayment = loan.amount + loan.interestAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go('/loan/details', extra: loan),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Loan ID: ${loan.id.substring(0, 6)}...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    currencyFormat.format(loan.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Application Date: ${dateFormat.format(loan.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Repayment Date: ${dateFormat.format(loan.repaymentDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 5),
              Text(
                // Display the correctly formatted percentage
                'Interest: ${currencyFormat.format(loan.interestAmount)} (${percentFormat.format(loan.interestRate)} daily)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Total Repayment: ${currencyFormat.format(totalRepayment)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(loan.status).withAlpha(51),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      loan.status,
                      style: TextStyle(
                        color: _getStatusColor(loan.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'on-hold':
        return Colors.grey;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
