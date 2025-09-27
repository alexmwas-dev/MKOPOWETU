import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
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
        title: const Text('FAQ'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _interstitialAdWidget.showAdWithCallback(() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            });
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          FaqItem(
            question: 'How do I apply for a loan?',
            answer:
                'You can apply for a loan directly from the home page by tapping the \'Apply Now\' button. Make sure your personal and financial information is complete and up to date for a higher chance of approval.',
          ),
          FaqItem(
            question: 'What are the interest rates?',
            answer:
                'Our interest rates vary depending on the loan amount and repayment period. The current interest rate is 5% of the principal amount.',
          ),
          FaqItem(
            question: 'How long does it take to get a loan?',
            answer:
                'Loan applications are typically processed within 3 minutes. You will receive a notification once your loan is approved.',
          ),
          FaqItem(
            question: 'How do I repay my loan?',
            answer:
                'You can repay your loan through M-Pesa or other mobile money platforms. Simply go to the loan details page and tap on the \'Repay Loan\' button.',
          ),
          FaqItem(
            question: 'What happens if I delay my repayment?',
            answer:
                'Late repayments may attract penalties and affect your credit score. It is advisable to repay your loan on time to maintain a good credit history.',
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(widget.question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isExpanded = isExpanded;
          });
        },
        trailing: Icon(_isExpanded ? Icons.remove : Icons.add,
            color: Theme.of(context).primaryColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.answer, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
