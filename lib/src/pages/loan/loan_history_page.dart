import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/bottom_nav_bar.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/loan_list_item.dart';
import 'package:mkopo_wetu/src/widgets/payment_list_item.dart';

class LoanHistoryPage extends StatefulWidget {
  final int initialTabIndex;
  const LoanHistoryPage({super.key, this.initialTabIndex = 0});

  @override
  State<LoanHistoryPage> createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAdWithCallback(() {});
    });
    // Fetching data is moved to didChangeDependencies to ensure context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch initial data when the widget is first built
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      Provider.of<LoanProvider>(context, listen: false).fetchLoans();
      Provider.of<PaymentProvider>(context, listen: false)
          .fetchPayments(user.uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Loan History'),
            Tab(text: 'Payment History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoanRecordView(),
          _buildPaymentRecordView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/loan/apply'),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(),
          BottomNavBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildLoanRecordView() {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        if (loanProvider.status == LoanStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final loans = loanProvider.loans;
        if (loans.isEmpty) {
          return _buildEmptyState(
              'No Loan History', 'Your loan applications will appear here.');
        }

        return ListView.builder(
          itemCount: loans.length,
          itemBuilder: (context, index) {
            final loan = loans[index];
            return LoanListItem(loan: loan);
          },
        );
      },
    );
  }

  Widget _buildPaymentRecordView() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.status == PaymentStatusUI.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final payments = paymentProvider.payments;

        if (payments.isEmpty) {
          return _buildEmptyState(
              'No Payment History', 'Your payment history will appear here.');
        }

        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return PaymentListItem(payment: payment);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
