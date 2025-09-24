import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';

class LoanTermsPage extends StatefulWidget {
  const LoanTermsPage({super.key});

  @override
  State<LoanTermsPage> createState() => _LoanTermsPageState();
}

class _LoanTermsPageState extends State<LoanTermsPage> {

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.getBannerAd();
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Terms'),
        centerTitle: true,
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
                  'To be eligible for a loan, you must be at least 18 years old and a registered user of the Okoa Loan app. You must also have a valid national ID and a registered mobile money account.',
            ),
            _buildTermSection(
              title: '2. Loan Application',
              content:
                  'All loan applications must be made through the Okoa Loan app. You will be required to provide accurate and complete information in your loan application. Okoa Loan reserves the right to approve or reject any loan application at its sole discretion.',
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
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
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
