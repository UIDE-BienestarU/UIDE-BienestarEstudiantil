import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/admin_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/login/login_screen.dart';

// Theme
import 'theme/app_theme.dart';

// Localization
//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const BienestarUIDE());
}

// Mantienes tu logout intacto (bien ahí)
void logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

class BienestarUIDE extends StatelessWidget {
  const BienestarUIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // 🔹 TÍTULO DESDE LOCALIZACIÓN
            //onGenerateTitle: (context) =>
               // AppLocalizations.of(context)!.appTitle,

            // 🔹 THEMES
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // 🔹 LOCALIZACIÓN
            //supportedLocales: const [
              //Locale('es'),
             // Locale('en'),
           // ],
            //localizationsDelegates: const [
             // AppLocalizations.delegate,
             // GlobalMaterialLocalizations.delegate,
             // GlobalWidgetsLocalizations.delegate,
             // GlobalCupertinoLocalizations.delegate,
            //],

            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
