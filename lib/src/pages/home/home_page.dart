import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/bottom_nav_bar.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/recipient_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();
  Timer? _notificationTimer;
  String? _notificationMessage;

  final _random = Random();
  final List<String> _phoneStarts = ['07', '01'];

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    _startNotificationTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAd();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<LoanProvider>(context, listen: false)
            .fetchLoans(authProvider.user!.uid);
      }
    });
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
            '$phoneStart****${phoneEnd.toString().substring(4)} received KSh$amount';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final latestLoan = loanProvider.loans.isNotEmpty ? loanProvider.loans.first : null;

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
          RefreshIndicator(
            onRefresh: () async {
              if (authProvider.user != null) {
                await Provider.of<LoanProvider>(context, listen: false)
                    .fetchLoans(authProvider.user!.uid);
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0,
                  150.0), // Padding for floating button and banner
              children: [
                _buildMainCard(context, latestLoan),
                const SizedBox(height: 24),
                _buildActionButtons(context, latestLoan),
                const SizedBox(height: 24),
                _buildInfoSubmissionRow(),
                const SizedBox(height: 32),
                _buildBorrowingGuide(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_notificationMessage != null)
            RecipientNotification(message: _notificationMessage!),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _interstitialAdWidget.showAd();
          context.go('/apply-loan');
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(),
          BottomNavBar(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, Loan? loan) {
    if (loan != null) {
      if (loan.status == 'pending') {
        // Auto-reject loan after 30 seconds
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && loan.status == 'pending') {
            Provider.of<LoanProvider>(context, listen: false).updateLoanStatus(loan.id, 'rejected');
          }
        });
      }
      switch (loan.status) {
        case 'pending':
          return _buildMessageCard(
            context,
            title: 'Your loan application is being reviewed',
            subtitle: 'Please be patient. This may take a few moments.',
            icon: Icons.hourglass_top_rounded,
            color: Colors.orange,
          );
        case 'rejected':
          final daysSinceRejection =
              DateTime.now().difference(loan.date).inDays;
          if (daysSinceRejection < 3) {
            final daysRemaining = 3 - daysSinceRejection;
            return _buildMessageCard(
              context,
              title: 'Your loan application has been rejected',
              subtitle:
                  'You can apply for another loan in $daysRemaining day(s).',
              icon: Icons.error_outline_rounded,
              color: Colors.red,
            );
          }
      }
    }
    return _buildLoanLimitCard();
  }

  Widget _buildLoanLimitCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Application Amount (KSh)',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('80,000',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Get loan within 3 minutes',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Maximum 365 days to repay',
                    style: TextStyle(color: Colors.white)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Loan? loan) {
    bool canApply = loan == null ||
        loan.status == 'paid' ||
        (loan.status == 'rejected' &&
            DateTime.now().difference(loan.date).inDays >= 3);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: canApply ? () {
              _interstitialAdWidget.showAd();
              context.go('/apply-loan');
            } : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            label: const Text('Loan Now'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history_outlined, size: 20),
            onPressed: () => context.go('/loan-history'),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1.5)),
            label: const Text('History'),
          ),
        ),
      ],
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
            'How it works?', Icons.help_outline, () => context.go('/faq')),
        _buildGuideItem(
            'How to repay?', Icons.payment, () => context.go('/faq')),
        _buildGuideItem('Improve loan limit', Icons.arrow_upward, () {}),
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
