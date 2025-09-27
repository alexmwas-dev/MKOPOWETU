import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:provider/provider.dart';

class FinancialInfoPage extends StatefulWidget {
  const FinancialInfoPage({super.key});

  @override
  State<FinancialInfoPage> createState() => _FinancialInfoPageState();
}

class _FinancialInfoPageState extends State<FinancialInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _employmentStatusController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _estimatedExpensesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _employmentStatusController.dispose();
    _monthlyIncomeController.dispose();
    _estimatedExpensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your Financial Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'This information helps us determine your loan limit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _employmentStatusController,
                decoration: const InputDecoration(
                    labelText: 'Employment Status',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Employment status is required.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: const InputDecoration(
                    labelText: 'Monthly Income',
                    prefixIcon: Icon(Icons.attach_money_outlined),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Monthly income is required.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _estimatedExpensesController,
                decoration: const InputDecoration(
                    labelText: 'Estimated Monthly Expenses',
                    prefixIcon: Icon(Icons.money_off_outlined),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? 'Estimated monthly expenses are required.'
                    : null,
              ),
              const SizedBox(height: 30),
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
                              double.parse(_estimatedExpensesController.text),
                            );
                            context.go('/home');
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Failed to save information. Please try again.')),
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
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Complete Setup',
                          style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
