import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:provider/provider.dart';

class PaymentTab extends StatefulWidget {
  final Loan? loan;
  final double? loanAmount;
  final int? repaymentDays;
  final double loanFee;
  final bool useCurrentUserPhone;

  const PaymentTab({
    super.key,
    this.loan,
    this.loanAmount,
    this.repaymentDays,
    required this.loanFee,
    required this.useCurrentUserPhone,
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
      loan: widget.loan,
      loanAmount: widget.loanAmount,
      repaymentDays: widget.repaymentDays,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    if (status != PaymentStatus.paid) {
      // ignore: use_build_context_synchronously
      _showResultDialog(context, status);
    }
  }

  void _showResultDialog(BuildContext context, PaymentStatus status) {
    String title, content;
    Color color;
    IconData icon;

    switch (status) {
      case PaymentStatus.failed:
        title = 'Payment Failed';
        content = 'Your payment could not be processed. Please try again.';
        color = Colors.red;
        icon = Icons.error;
        break;
      case PaymentStatus.paid:
        title = 'Payment Success';
        content = 'Your payment was received, your loan status has been updated.';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PaymentStatus.cancelled:
        title = 'Payment Cancelled';
        content = 'The payment was cancelled.';
        color = Colors.orange;
        icon = Icons.cancel;
        break;
      case PaymentStatus.timeout:
        title = 'Payment Timeout';
        content = 'The payment request timed out. Please try again.';
        color = Colors.grey;
        icon = Icons.timer_off;
        break;
      default:
        return;
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
            onPressed: () => Navigator.of(context).pop(),
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
                    return 'Invalid format. Use 2547...';
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
                        'A payment prompt will be sent to your phone.Please note that this amount is Refundable',
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
              onPressed: paymentProvider.status == PaymentStatus.loading
                  ? null
                  : () => _processPayment(context),
              child: paymentProvider.status == PaymentStatus.loading
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
