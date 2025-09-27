import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/providers/connectivity_provider.dart';
import 'package:mkopo_wetu/src/providers/loan_provider.dart';
import 'package:mkopo_wetu/src/providers/payment_provider.dart';
import 'package:mkopo_wetu/src/providers/theme_provider.dart';
import 'package:mkopo_wetu/src/providers/user_provider.dart';
import 'package:mkopo_wetu/src/router/app_router.dart';
import 'package:mkopo_wetu/src/services/user_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => LoanProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(
          create: (context) => UserProvider(UserService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appRouter = AppRouter(authProvider);

    const Color primaryColor = Color(0xFF00C853); // Emerald Green
    const Color lightGreenBackground = Color(0xFFF0FFF4);
    const Color cardBackgroundColor = Colors.white;
    const Color textColor = Color(0xFF2C2C2C);

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: textColor),
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: textColor),
      labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightGreenBackground,
      cardColor: cardBackgroundColor, // Kept for backwards compatibility
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        surface: cardBackgroundColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightGreenBackground,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final ThemeData darkTheme = lightTheme;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: appRouter.router,
          title: 'Mkopo Wetu',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
