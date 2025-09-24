import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/auth_provider.dart';

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
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.getBannerAd();
    _bannerAd?.load();

    // Safely access the provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        _employmentStatusController.text = user.employmentStatus ?? '';
        _monthlyIncomeController.text = user.monthlyIncome?.toString() ?? '';
        _monthlyExpensesController.text = user.monthlyExpenses?.toString() ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _employmentStatusController.dispose();
    _monthlyIncomeController.dispose();
    _monthlyExpensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Details')),
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
                validator: (value) => value!.isEmpty ? 'Please enter your employment status' : null,
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
                  if (value!.isEmpty) return 'Please enter your monthly income';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
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
                  if (value!.isEmpty) return 'Please enter your monthly expenses';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
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
                            await authProvider.updateFinancialDetails(
                              _employmentStatusController.text,
                              double.parse(_monthlyIncomeController.text),
                              double.parse(_monthlyExpensesController.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Financial details saved!')),
                            );
                            context.go('/profile'); // Navigate back to profile
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save details: ${e.toString()}')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                      child: const Text('Save & Continue'),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
