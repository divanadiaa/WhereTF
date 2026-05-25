import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'features/landing/splash_screen.dart';

class WhereTFApp extends StatelessWidget {
  const WhereTFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'whereTF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}