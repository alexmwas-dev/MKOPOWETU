import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:mkopo_wetu/src/services/config_service.dart';
import 'package:mkopo_wetu/src/widgets/payment_success_screen.dart';
import 'package:mkopo_wetu/src/widgets/payment_tab.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  final Loan? loan;
  final double? loanAmount;
  final int? repaymentDays;

  const PaymentPage({super.key, this.loan, this.loanAmount, this.repaymentDays});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConfigService _configService = ConfigService();
  double? _loanFee;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLoanFee();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).resetStatus();
    });
  }

  Future<void> _fetchLoanFee() async {
    try {
      final fee = await _configService.getLoanFee();
      setState(() {
        _loanFee = fee;
      });
    } catch (e) {
      // Handle error
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
              : () => context.go('/loan/history', extra: {'initialTabIndex': 1}),
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
      body: _loanFee == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                PaymentTab(
                  loan: widget.loan,
                  loanAmount: widget.loanAmount,
                  repaymentDays: widget.repaymentDays,
                  loanFee: _loanFee!,
                  useCurrentUserPhone: true,
                ),
                PaymentTab(
                  loan: widget.loan,
                  loanAmount: widget.loanAmount,
                  repaymentDays: widget.repaymentDays,
                  loanFee: _loanFee!,
                  useCurrentUserPhone: false,
                ),
              ],
            ),
    );
  }
}
