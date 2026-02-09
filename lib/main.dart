import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/admin_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/avisos_provider.dart';
import 'providers/notificaciones_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/solicitud_provider.dart';

// ✅ Objetos Perdidos
import 'providers/objetos_perdidos_provider.dart';

// ✅ Screens
import 'screens/login/login_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/student/student_objetos_perdidos.dart';

import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

// ✅ navigatorKey global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ Handler notificaciones background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const BienestarUIDE());
}

// ✅ Logout global
void logout() {
  final nav = navigatorKey.currentState;
  if (nav == null) return;

  nav.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AvisosProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => SolicitudProvider()),
        ChangeNotifierProvider(create: (_) => ObjetosPerdidosProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,

            // 🌍 Localización
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 🎨 Tema
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // ✅ RUTAS (LO ÚNICO NUEVO)
            routes: {
              '/student_objetos_perdidos': (_) =>
                  const StudentObjetosPerdidosScreen(),
            },

            // ✅ AuthGate
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
