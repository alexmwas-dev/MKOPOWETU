import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/auth_provider.dart';
import 'package:okoa_loan/src/providers/loan_provider.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';

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

  @override
  void initState() {
    super.initState();
    AdManager.loadInterstitialAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    AdManager.getInterstitialAd()?.dispose();
    _loanAmount.dispose();
    _repaymentDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLoanAmountCard(currencyFormatter),
              const SizedBox(height: 24),
              _buildRepaymentPeriodCard(),
               const SizedBox(height: 24),
              _buildInfoStatusTile('Personal Info', _personalInfoCompleted, () => context.go('/profile/edit')),
              _buildInfoStatusTile('Residential Info', _residentialInfoCompleted, () => context.go('/profile/edit')),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_personalInfoCompleted || !_residentialInfoCompleted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please complete your profile information first.')),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                           setState(() => _isLoading = true);
                           try {
                              await Provider.of<LoanProvider>(context, listen: false)
                                  .applyForLoan(authProvider.user!.uid, _loanAmount.value);
                              
                              final interstitialAd = AdManager.getInterstitialAd();
                              if (interstitialAd != null) {
                                  interstitialAd.show();
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Loan application submitted successfully!')),
                                );
                                context.go('/home');
                              }
                           } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to apply: ${e.toString()}')),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm Application', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
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
                    const Text('Loan Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text('Repayment Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                divisions: (365-30) ~/ 5,
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


  Widget _buildInfoStatusTile(String title, bool completed, VoidCallback onEdit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(completed ? Icons.check_circle : Icons.cancel_outlined, color: completed ? Colors.green : Colors.red, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(completed ? 'Completed' : 'Incomplete', style: TextStyle(color: completed ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
