import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/connectivity_provider.dart';
import 'package:okoa_loan/src/providers/theme_provider.dart';
import 'package:okoa_loan/src/router/app_router.dart';
import 'package:okoa_loan/src/theme/theme.dart';
import 'package:okoa_loan/src/widgets/no_internet_widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Okoa Loan',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return connectivityProvider.hasInternet
            ? child!
            : const NoInternetWidget();
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
