import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class FinancialDetailsPage extends StatefulWidget {
  const FinancialDetailsPage({super.key});

  @override
  State<FinancialDetailsPage> createState() => _FinancialDetailsPageState();
}

class _FinancialDetailsPageState extends State<FinancialDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _employmentStatusController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  bool _isLoading = false;
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAd();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        _employmentStatusController.text = user.employmentStatus ?? '';
        _monthlyIncomeController.text = user.monthlyIncome?.toString() ?? '';
        _monthlyExpensesController.text =
            user.monthlyExpenses?.toString() ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _employmentStatusController.dispose();
    _monthlyIncomeController.dispose();
    _monthlyExpensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _employmentStatusController,
                decoration: const InputDecoration(
                  labelText: 'Employment Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your employment status.' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your monthly income.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _monthlyExpensesController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Expenses',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your monthly expenses.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            await authProvider.updateFinancialInfo(
                              _employmentStatusController.text,
                              double.parse(_monthlyIncomeController.text),
                              double.parse(_monthlyExpensesController.text),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Your financial details have been saved successfully.')),
                              );
                              context.go('/profile');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'An error occurred while saving your details. Please try again.')),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0)),
                      child: const Text('Save & Continue'),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
