import 'package:flutter/material.dart';
import 'package:okoa_loan/src/widgets/ad_banner.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTermSection(
              title: '1. Introduction',
              content:
                  'By accessing and using the Okoa Loan mobile application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use our application.',
            ),
            _buildTermSection(
              title: '2. Eligibility',
              content:
                  'To be eligible for a loan, you must be at least 18 years old and a resident of Kenya. You must also provide accurate and complete information during the registration process.',
            ),
            _buildTermSection(
              title: '3. Loan Application and Approval',
              content:
                  'All loan applications are subject to approval by Okoa Loan. We reserve the right to approve or reject any loan application at our sole discretion. We may also determine the loan amount and repayment terms based on our assessment of your creditworthiness.',
            ),
            _buildTermSection(
              title: '4. Repayment',
              content:
                  'You are responsible for repaying your loan on time, according to the agreed-upon repayment schedule. Failure to make timely payments may result in late fees and other penalties.',
            ),
            _buildTermSection(
              title: '5. User Conduct',
              content:
                  'You agree not to use the Okoa Loan application for any unlawful or prohibited activities. You must not attempt to interfere with the proper functioning of the application or compromise its security.',
            ),
            _buildTermSection(
              title: '6. Limitation of Liability',
              content:
                  'Okoa Loan is not liable for any damages or losses that may arise from your use of our application. We do not guarantee the availability or accuracy of the information provided in the app.',
            ),
            _buildTermSection(
              title: '7. Changes to Terms',
              content:
                  'We reserve the right to modify these Terms and Conditions at any time. Any changes will be effective immediately upon posting the updated terms in the application. Your continued use of the app after any such changes constitutes your acceptance of the new terms.',
            ),
            _buildTermSection(
              title: '8. Contact Us',
              content:
                  'If you have any questions or concerns about these Terms and Conditions, please contact us at support@okoaloan.com.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBanner(),
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
