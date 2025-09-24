import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okoa_loan/src/models/loan_model.dart';

class LoanDetailsPage extends StatelessWidget {
  final Loan loan;

  const LoanDetailsPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final repaymentDate = loan.date.add(Duration(days: loan.repaymentPeriod));
    final interest = loan.amount * 0.05; // 5% interest
    final totalRepayable = loan.amount + interest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 24),
          _buildDetailsCard(context, repaymentDate, totalRepayable, interest),
          const SizedBox(height: 24),
          if (loan.status == 'approved')
            ElevatedButton.icon(
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text('Repay Loan', style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: () { /* Repayment logic here */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final statusText = loan.status.substring(0, 1).toUpperCase() + loan.status.substring(1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
           gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text('Loan Amount', style: TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              'KSh ${loan.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text(statusText, style: TextStyle(color: _getStatusColor(loan.status), fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, DateTime repaymentDate, double totalRepayable, double interest) {
     return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            _buildDetailRow('Order Number', loan.id, icon: Icons.confirmation_number_outlined),
            _buildDetailRow('Loan Term', '${loan.repaymentPeriod} days', icon: Icons.date_range_outlined),
            _buildDetailRow('Filing Date', DateFormat('MMM dd, yyyy').format(loan.date), icon: Icons.calendar_today_outlined),
            _buildDetailRow('Repayment Date', DateFormat('MMM dd, yyyy').format(repaymentDate), icon: Icons.event_available_outlined),
            const Divider(height: 24),
            _buildDetailRow('Interest (5%)', 'KSh ${interest.toStringAsFixed(2)}', icon: Icons.trending_up_outlined),
            _buildDetailRow('Amount Repayable', 'KSh ${totalRepayable.toStringAsFixed(2)}', icon: Icons.receipt_long_outlined, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {required IconData icon, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
