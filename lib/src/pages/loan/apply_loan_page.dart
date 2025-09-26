import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class ApplyLoanPage extends StatefulWidget {
  const ApplyLoanPage({super.key});

  @override
  State<ApplyLoanPage> createState() => _ApplyLoanPageState();
}

class _ApplyLoanPageState extends State<ApplyLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<double> _loanAmount = ValueNotifier<double>(5000.0);
  final ValueNotifier<int> _repaymentDays = ValueNotifier<int>(30);

  bool _personalInfoCompleted = false;
  bool _residentialInfoCompleted = false;

  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();
  Future<Map<String, dynamic>>? _eligibilityFuture;

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          _personalInfoCompleted = user.isPersonalInfoComplete();
          _residentialInfoCompleted = user.isResidentialInfoComplete();
          _eligibilityFuture = Provider.of<LoanProvider>(context, listen: false).isEligibleForLoan();
        });
      }
    });
  }

  @override
  void dispose() {
    _loanAmount.dispose();
    _repaymentDays.dispose();
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  void _navigateToPayment() {
    _interstitialAdWidget.showAdWithCallback(() {
      context.push(
        '/loan/payment',
        extra: {
          'loanAmount': _loanAmount.value,
          'repaymentDays': _repaymentDays.value,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        centerTitle: true,
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
      ),
      body: _buildBody(context),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _eligibilityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildStatusIndicator(
            icon: Icons.error,
            color: Colors.red,
            message: 'Error: ${snapshot.error}',
          );
        }

        final eligibility = snapshot.data;
        if (eligibility != null && !eligibility['eligible']) {
          return _buildStatusIndicator(
            icon: Icons.block,
            color: Colors.red,
            message: eligibility['message'],
          );
        }

        return _buildApplicationForm();
      },
    );
  }

  Widget _buildApplicationForm() {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLoanAmountCard(currencyFormatter),
            const SizedBox(height: 24),
            _buildRepaymentPeriodCard(),
            const SizedBox(height: 24),
            _buildInterestDetailsCard(currencyFormatter),
            const SizedBox(height: 24),
            _buildInfoStatusTile('Personal Info', _personalInfoCompleted,
                () => context.go('/profile/edit')),
            _buildInfoStatusTile('Residential Info', _residentialInfoCompleted,
                () => context.go('/profile/edit')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (!_personalInfoCompleted || !_residentialInfoCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please complete your profile before applying.')),
                  );
                  return;
                }
                _navigateToPayment();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed to Payment',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
      {required IconData icon, required Color color, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 80),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanAmountCard(NumberFormat formatter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loan Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: _loanAmount,
              builder: (context, value, child) {
                return Center(
                  child: Text(
                    formatter.format(value),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: _loanAmount,
              builder: (context, value, child) {
                return Slider(
                  value: value,
                  min: 1000,
                  max: 80000,
                  divisions: 79,
                  label: formatter.format(value),
                  onChanged: (newValue) {
                    _loanAmount.value = newValue;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepaymentPeriodCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Repayment Period',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: _repaymentDays,
              builder: (context, value, child) {
                return Center(
                  child: Text(
                    '$value days',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: _repaymentDays,
              builder: (context, value, child) {
                return Slider(
                  value: value.toDouble(),
                  min: 18,
                  max: 62,
                  divisions: (62 - 18) ~/ 5,
                  label: '$value days',
                  onChanged: (newValue) {
                    _repaymentDays.value = newValue.round();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestDetailsCard(NumberFormat formatter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loan Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: _loanAmount,
              builder: (context, loanAmount, child) {
                return ValueListenableBuilder<int>(
                  valueListenable: _repaymentDays,
                  builder: (context, repaymentDays, child) {
                    final interest = loanAmount * 0.002 * repaymentDays;
                    final totalRepayment = loanAmount + interest;
                    return Column(
                      children: [
                        _buildDetailRow('Interest Rate:', '0.2% per day'),
                        const SizedBox(height: 8),
                        _buildDetailRow('Interest Amount:', formatter.format(interest)),
                        const SizedBox(height: 8),
                         const Divider(),
                        const SizedBox(height: 8),
                        _buildDetailRow('Total Repayment:', formatter.format(totalRepayment), isTotal: true),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 20 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? Theme.of(context).primaryColor : null,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(fontWeight: FontWeight.w500)),
        Text(value, style: style),
      ],
    );
}


  Widget _buildInfoStatusTile(
      String title, bool completed, VoidCallback onEdit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(completed ? Icons.check_circle : Icons.cancel_outlined,
            color: completed ? Colors.green : Colors.red, size: 28),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(completed ? 'Completed' : 'Incomplete',
                style: TextStyle(
                    color: completed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
