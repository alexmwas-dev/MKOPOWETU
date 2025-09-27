import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/widgets/payment_success_screen.dart';
import 'package:mkopo_wetu/src/widgets/payment_tab.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class PaymentPage extends StatefulWidget {
  final Loan? loan;
  final double? loanAmount;
  final int? repaymentDays;

  const PaymentPage(
      {super.key, this.loan, this.loanAmount, this.repaymentDays});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConfigService _configService = ConfigService();
  Future<double>? _loanFeeFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loanFeeFuture = _fetchLoanFee();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).resetStatus();
    });
  }

  Future<double> _fetchLoanFee() async {
    try {
      return await _configService.getLoanFee();
    } catch (e, s) {
      developer.log(
        'Failed to fetch or parse loan fee. Using default value.',
        name: 'PaymentPage',
        error: e,
        stackTrace: s,
      );
      return 210.0; // Return a default value
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    if (paymentProvider.status == PaymentStatus.success) {
      return const PaymentSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: paymentProvider.status == PaymentStatus.loading
              ? null
              : () =>
                  context.go('/loan/history', extra: {'initialTabIndex': 1}),
        ),
        title: const Text('Make Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Number'),
            Tab(text: 'Other Number'),
          ],
        ),
      ),
      body: FutureBuilder<double>(
        future: _loanFeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // This part might not be reached if you always return a default value,
            // but it's good practice for robustness.
            return const Center(child: Text('Error loading loan fee.'));
          } else if (snapshot.hasData) {
            final loanFee = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                PaymentTab(
                  loan: widget.loan,
                  loanAmount: widget.loanAmount,
                  repaymentDays: widget.repaymentDays,
                  loanFee: loanFee,
                  useCurrentUserPhone: true,
                ),
                PaymentTab(
                  loan: widget.loan,
                  loanAmount: widget.loanAmount,
                  repaymentDays: widget.repaymentDays,
                  loanFee: loanFee,
                  useCurrentUserPhone: false,
                ),
              ],
            );
          } else {
            // This case should ideally not be reached with the current logic
            return const Center(child: Text('An unexpected error occurred.'));
          }
        },
      ),
    );
  }
}
