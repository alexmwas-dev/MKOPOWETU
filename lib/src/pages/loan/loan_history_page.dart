import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/widgets/bottom_nav_bar.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class LoanHistoryPage extends StatefulWidget {
  const LoanHistoryPage({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAd();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan History'),
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
            Tab(text: 'Loan Records'),
            Tab(text: 'Payment Records'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoanRecordView(),
                _buildPaymentRecordView(),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/apply-loan'),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLoanRecordView() {
    final loanProvider = Provider.of<LoanProvider>(context);

    if (loanProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loanProvider.loans.isEmpty) {
      return _buildEmptyState(
          'No loan records found.', 'Apply for a loan to get started.');
    }

    return ListView.builder(
      itemCount: loanProvider.loans.length,
      itemBuilder: (context, index) {
        final loan = loanProvider.loans[index];
        return _buildLoanRecordItem(context, loan);
      },
    );
  }

  Widget _buildPaymentRecordView() {
    // For now, this is a placeholder as we don't have payment data
    return _buildEmptyState('No payment records yet.',
        'Your successful payments will appear here.');
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildLoanRecordItem(BuildContext context, Loan loan) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(loan.date);
    final statusColor = _getStatusColor(loan.status);
    final statusText =
        loan.status.substring(0, 1).toUpperCase() + loan.status.substring(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        title: Text(
          'Loan of KSh ${loan.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Applied on: $formattedDate',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.go('/loan-details', extra: loan),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
