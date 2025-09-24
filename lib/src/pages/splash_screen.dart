import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _navigateToNext();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 4), () {
      context.go('/intro');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.monetization_on,
              size: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Okoa Loan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 50),
            if (_version.isNotEmpty)
              Text(
                'Version $_version',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
