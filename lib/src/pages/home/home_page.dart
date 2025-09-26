import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/bottom_nav_bar.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/recipient_notification.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();
  Timer? _notificationTimer;
  String? _notificationMessage;
  Future<void>? _loadDataFuture;

  final _random = Random();
  final List<String> _phoneStarts = ['07', '01'];

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    _startNotificationTimer();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _loadDataFuture = Provider.of<LoanProvider>(context, listen: false).fetchLoans();
    }
  }

  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _generateRandomNotification();
    });
  }

  void _generateRandomNotification() {
    final phoneStart = _phoneStarts[_random.nextInt(_phoneStarts.length)];
    final phoneEnd = _random.nextInt(90000000) + 10000000;
    final amount = (_random.nextInt(20) + 1) * 1000;
    if (mounted) {
      setState(() {
        _notificationMessage =
            '$phoneStart****${phoneEnd.toString().substring(4)} received KSh $amount';
      });
    }
    // Notification will disappear after a few seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _notificationMessage = null);
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome, ${authProvider.user?.name ?? 'User'}'),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.person_pin, size: 32),
              onPressed: () => context.go('/profile')),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 150.0),
            children: [
              _buildLoanStatusCard(),
              const SizedBox(height: 24),
              _buildInfoSubmissionRow(),
              const SizedBox(height: 32),
              _buildBorrowingGuide(context),
              const SizedBox(height: 20),
            ],
          ),
          if (_notificationMessage != null)
            RecipientNotification(message: _notificationMessage!),
        ],
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(),
          BottomNavBar(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildLoanStatusCard() {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        return FutureBuilder(
          future: _loadDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingLoanCard();
            }

            final latestLoan = loanProvider.loans.isNotEmpty ? loanProvider.loans.first : null;

            return FutureBuilder<Map<String, dynamic>>(
              future: loanProvider.isEligibleForLoan(),
              builder: (context, eligibilitySnapshot) {
                if (eligibilitySnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingLoanCard();
                }

                bool isEligible = false;
                String eligibilityMessage = '';

                if (eligibilitySnapshot.hasData) {
                  isEligible = eligibilitySnapshot.data!['eligible'];
                  eligibilityMessage = eligibilitySnapshot.data!['message'] ?? '';
                }

                String title = 'Apply for a Loan';
                String subtitle = 'You are eligible for a new loan.';
                IconData icon = Icons.check_circle_outline_rounded;
                Color cardColor = Theme.of(context).primaryColor;
                String buttonText = 'Apply Now';
                VoidCallback? onPressed = () => context.go('/loan/apply');

                if (latestLoan != null) {
                  switch (latestLoan.status) {
                    case 'pending':
                      title = 'Loan Pending';
                      subtitle = 'Your application is under review.';
                      icon = Icons.hourglass_empty_rounded;
                      cardColor = Colors.orange;
                      buttonText = 'View Details';
                      onPressed = () => context.go('/loan/details', extra: latestLoan);
                      break;
                    case 'approved':
                      title = 'Loan Approved';
                      subtitle = 'Congratulations! Your loan of KSh ${NumberFormat('#,##0').format(latestLoan.amount)} is ready.';
                      icon = Icons.check_circle_rounded;
                      cardColor = Colors.green;
                      buttonText = 'View Loan';
                      onPressed = () => context.go('/loan/details', extra: latestLoan);
                      break;
                    case 'on-hold':
                      title = 'Payment Required';
                      subtitle = 'A payment is required to process your application.';
                      icon = Icons.payment_rounded;
                      cardColor = Colors.blue;
                      buttonText = 'Make Payment';
                      onPressed = () => context.push('/loan/payment', extra: {'loan': latestLoan});
                      break;
                    case 'rejected':
                      title = 'Loan Rejected';
                      subtitle = eligibilityMessage;
                      icon = Icons.cancel_rounded;
                      cardColor = Colors.red;
                      buttonText = 'Apply Again';
                      onPressed = isEligible ? () => context.go('/loan/apply') : null;
                      break;
                    case 'paid':
                      title = 'All Loans Paid';
                      subtitle = 'You have no outstanding loans.';
                      icon = Icons.verified_user_rounded;
                      cardColor = Theme.of(context).primaryColor;
                      break;
                  }
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 40, color: Colors.white),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(subtitle, style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.white,
                            foregroundColor: cardColor,
                          ),
                          child: Text(buttonText),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


  Widget _buildLoadingLoanCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 200,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoSubmissionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildIconWithText('Submit Info', Icons.article_outlined,
            () => context.go('/profile/edit')),
        _buildIconWithText('Get Credit', Icons.trending_up, () {}),
        _buildIconWithText(
            'Get Money', Icons.account_balance_wallet_outlined, () {}),
      ],
    );
  }

  Widget _buildIconWithText(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withAlpha(25),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700]))
        ],
      ),
    );
  }

  Widget _buildBorrowingGuide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Borrowing Guide',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildGuideItem(
            'How It Works', Icons.help_outline, () => context.go('/faq')),
        _buildGuideItem(
            'How to Repay', Icons.payment, () => context.go('/faq')),
        _buildGuideItem('Improve Loan Limit', Icons.arrow_upward, () {}),
      ],
    );
  }

  Widget _buildGuideItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading:            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
