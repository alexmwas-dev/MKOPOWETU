import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {

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
        title: const Text('FAQ'),
        centerTitle: true,
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
        title: Text(widget.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isExpanded = isExpanded;
          });
        },
        trailing: Icon(_isExpanded ? Icons.remove : Icons.add, color: Theme.of(context).primaryColor),
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
