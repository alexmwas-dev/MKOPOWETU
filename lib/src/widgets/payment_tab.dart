import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:provider/provider.dart';

class PaymentTab extends StatefulWidget {
  final Loan? loan;
  final String loanId;
  final double? loanAmount;
  final int? repaymentDays;
  final double loanFee;
  final bool useCurrentUserPhone;
  final double interestRate;

  const PaymentTab({
    super.key,
    this.loan,
    required this.loanId,
    this.loanAmount,
    this.repaymentDays,
    required this.loanFee,
    required this.useCurrentUserPhone,
    required this.interestRate,
  });

  @override
  State<PaymentTab> createState() => _PaymentTabState();
}

class _PaymentTabState extends State<PaymentTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  Future<void> _processPayment(BuildContext context) async {
    if (!widget.useCurrentUserPhone && !_formKey.currentState!.validate()) {
      return;
    }

    final paymentProvider = context.read<PaymentProvider>();
    final authProvider = context.read<AuthProvider>();
    final loanProvider = context.read<LoanProvider>();
    final user = authProvider.user;

    if (user == null) {
      // Handle user not logged in case
      return;
    }

    final phone =
        widget.useCurrentUserPhone ? user.phoneNumber : _phoneController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing payment..."),
            ],
          ),
        ),
      ),
    );

    final status = await paymentProvider.initiatePayment(
      amount: widget.loanFee,
      phoneNumber: phone,
      loanProvider: loanProvider,
      userId: user.uid,
      loanId: widget.loanId,
      loanAmount: widget.loanAmount,
      repaymentDays: widget.repaymentDays,
      interestRate: widget.interestRate,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(); // Close the processing dialog

    // ignore: use_build_context_synchronously
    _showResultDialog(context, status);
  }

  void _showResultDialog(BuildContext context, PaymentStatusUI status) {
    String title, content;
    Color color;
    IconData icon;

    switch (status) {
      case PaymentStatusUI.failed:
        title = 'Payment Failed';
        content =
            'Your payment could not be processed. Please check your details and try again.';
        color = Colors.red;
        icon = Icons.error;
        break;
      case PaymentStatusUI.paid:
        title = 'Payment Successful';
        content =
            'Your payment was received, and your loan status has been updated. You can check the loan status on the home page.';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PaymentStatusUI.cancelled:
        title = 'Payment Cancelled';
        content =
            'You cancelled the payment. You can try again if you wish to proceed.';
        color = Colors.orange;
        icon = Icons.cancel;
        break;
      case PaymentStatusUI.timeout:
        title = 'Payment Timeout';
        content =
            'The payment request timed out. Please try again. Ensure you have a stable internet connection.';
        color = Colors.grey;
        icon = Icons.timer_off;
        break;
      default:
        // For statuses like 'initiated' or 'loading', which shouldn't normally be shown here
        title = 'Payment In Progress';
        content =
            'The payment is still being processed. You will be notified shortly.';
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (status == PaymentStatusUI.paid) {
                // Optionally navigate to a specific screen after success
                // For example, back to the main loan list
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_KE', symbol: 'KES');
    final paymentProvider = context.watch<PaymentProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.useCurrentUserPhone)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Valid phone number required.';
                  }
                  if (!RegExp(r'^(?:254)?[0-9]{9}$').hasMatch(value)) {
                    return 'Invalid format. Use 254...';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: currencyFormat.format(widget.loanFee),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Application Fee',
                prefixIcon: const Icon(Icons.money),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A payment prompt will be sent to your phone. Please note that this amount is Refundable if the loan is not approved.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: paymentProvider.status == PaymentStatusUI.loading
                  ? null
                  : () => _processPayment(context),
              child: paymentProvider.status == PaymentStatusUI.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Proceed to Pay',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
