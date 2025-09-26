import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class LoanTermsPage extends StatefulWidget {
  const LoanTermsPage({super.key});

  @override
  State<LoanTermsPage> createState() => _LoanTermsPageState();
}

class _LoanTermsPageState extends State<LoanTermsPage> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAdWithCallback(() {});
    });
  }

  @override
  void dispose() {
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Terms'),
        centerTitle: true,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Terms and Conditions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTermSection(
              title: '1. Eligibility',
              content:
                  'To be eligible for a loan, you must be at least 18 years old and a registered user of the Mkopo Wetu app. You must also have a valid national ID and a registered mobile money account.',
            ),
            _buildTermSection(
              title: '2. Loan Application',
              content:
                  'All loan applications must be made through the Mkopo Wetu app. You will be required to provide accurate and complete information in your loan application. Mkopo Wetu reserves the right to approve or reject any loan application at its sole discretion.',
            ),
            _buildTermSection(
              title: '3. Interest and Fees',
              content:
                  'All loans are subject to an interest rate of 5% of the principal amount. Additional fees may apply for late repayments. All applicable fees will be clearly communicated to you before you accept the loan.',
            ),
            _buildTermSection(
              title: '4. Repayment',
              content:
                  'You are required to repay your loan in full on or before the due date. You can make repayments through M-Pesa or other mobile money platforms. Late repayments will attract a penalty and may affect your credit score.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildTermSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
