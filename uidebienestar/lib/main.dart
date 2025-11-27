// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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


class BienestarUIDE extends StatelessWidget {
  const BienestarUIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Bienestar Estudiantil UIDE',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: UIDEColors.conchevino,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}