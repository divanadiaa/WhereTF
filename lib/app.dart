import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'features/landing/splash_screen.dart';
import 'state/session_controller.dart';

class WhereTFApp extends StatelessWidget {
  const WhereTFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionController(),
      child: MaterialApp(
        title: 'whereTF',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
