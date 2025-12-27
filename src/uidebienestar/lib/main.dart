// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'providers/admin_provider.dart';
import 'screens/login/login_screen.dart';
import 'theme/uide_colors.dart';

void main() {
  runApp(const BienestarUIDE());
}

void logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

class BienestarUIDE extends StatefulWidget {
  const BienestarUIDE({super.key});

  @override
  State<BienestarUIDE> createState() => _BienestarUIDEState();
}

class _BienestarUIDEState extends State<BienestarUIDE> {
  // Idioma actual de la app. Por defecto español
  Locale _locale = const Locale('es');

  // Función para cambiar el idioma (la usaremos desde un botón temporal)
  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        // Título dinámico que cambia con el idioma
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

        // Idioma activo
        locale: _locale,

        // Delegados de localización
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Idiomas soportados (automáticamente detecta los .arb)
        supportedLocales: AppLocalizations.supportedLocales,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: UIDEColors.conchevino,
        ),

        home: HomeWithLanguageSwitcher(
          changeLocale: _changeLocale,  // Pasamos la función al home
        ),

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget temporal solo para pruebas y capturas del entregable
class HomeWithLanguageSwitcher extends StatelessWidget {
  final void Function(Locale) changeLocale;

  const HomeWithLanguageSwitcher({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoginScreen(),  // Tu pantalla normal

        // Botón flotante temporal en la esquina superior derecha
        Positioned(
          top: 60,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              final currentLocale = Localizations.localeOf(context);
              final newLocale = currentLocale.languageCode == 'es'
                  ? const Locale('en')
                  : const Locale('es');
              changeLocale(newLocale);
            },
            backgroundColor: UIDEColors.conchevino.withOpacity(0.8),
            child: const Icon(Icons.language, size: 20),
          ),
        ),
      ],
    );
  }
}