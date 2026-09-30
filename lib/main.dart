import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/properties_provider.dart';
import 'providers/projects_provider.dart';
import 'providers/notifications_provider.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AhlamApp());
}

class AhlamApp extends StatelessWidget {
  const AhlamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => PropertiesProvider()),
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = AppRouter.createRouter(auth);
          return MaterialApp.router(
            title: 'أحلام الشرق العقارية',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            locale: const Locale('ar', 'YE'),
            supportedLocales: const [Locale('ar', 'YE')],
            theme: _buildTheme(),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A3B5C),
        brightness: Brightness.light,
        primary: const Color(0xFF1A3B5C),
        secondary: const Color(0xFFB59659),
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A3B5C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3B5C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A3B5C),
          side: const BorderSide(color: Color(0xFF1A3B5C)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3B5C), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF1A3B5C),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
