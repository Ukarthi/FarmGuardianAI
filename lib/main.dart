import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmGuardianApp());
}

class FarmGuardianApp extends StatelessWidget {
  const FarmGuardianApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmGuardian AI',
      debugShowCheckedModeBanner: false,
      
      // Material Design 3 Theme configuration
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          background: AppColors.background,
          surface: AppColors.cardBg,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
        ),
        
        // Load premium Outfit typography dynamically
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textMain),
          bodyMedium: const TextStyle(color: AppColors.textMain),
        ),
        
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBg,
          elevation: 2,
        ),
        
        cardTheme: const CardTheme(
          color: AppColors.cardBg,
          elevation: 4,
        ),
      ),
      
      // Set the root entry screen
      home: const SplashScreen(),
    );
  }
}
