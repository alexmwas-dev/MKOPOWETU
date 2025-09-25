import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
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
  bool _isLoading = false;

  bool _personalInfoCompleted = false;
  bool _residentialInfoCompleted = false;

  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAd();
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          _personalInfoCompleted = user.isPersonalInfoComplete();
          _residentialInfoCompleted = user.isResidentialInfoComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _loanAmount.dispose();
    _repaymentDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loanProvider = Provider.of<LoanProvider>(context);
    final latestLoan = loanProvider.loans.isNotEmpty ? loanProvider.loans.first : null;

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
      body: _buildBody(context, authProvider, latestLoan),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildBody(
      BuildContext context, AuthProvider authProvider, Loan? latestLoan) {
    if (latestLoan != null && latestLoan.status == 'rejected') {
      final daysSinceRejection = DateTime.now().difference(latestLoan.date).inDays;
      if (daysSinceRejection < 3) {
        final daysRemaining = 3 - daysSinceRejection;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Your previous loan application was not successful. Please try again in $daysRemaining day(s).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    }

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
            _buildInfoStatusTile('Personal Info', _personalInfoCompleted,
                () => context.go('/profile/edit')),
            _buildInfoStatusTile('Residential Info', _residentialInfoCompleted,
                () => context.go('/profile/edit')),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (!_personalInfoCompleted || !_residentialInfoCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please complete your personal and residential information before applying for a loan.')),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          await Provider.of<LoanProvider>(context, listen: false)
                              .applyForLoan(
                                  authProvider.user!.uid, _loanAmount.value);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Your loan application has been submitted successfully.')),
                            );
                            context.go('/home');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('There was an error submitting your loan application. Please try again.')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Application',
                        style: TextStyle(fontSize: 18)),
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
                  min: 30,
                  max: 365,
                  divisions: (365 - 30) ~/ 5,
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
