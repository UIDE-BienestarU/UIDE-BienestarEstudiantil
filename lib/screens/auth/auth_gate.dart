import 'package:flutter/material.dart';
import '../../services/token_storage.dart';
import '../../services/jwt_utils.dart';

import '../login/login_screen.dart';
import '../student/student_dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Widget? _screen;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final access = await TokenStorage.getAccessToken();
    final refresh = await TokenStorage.getRefreshToken();

    final loggedIn = (access != null && access.isNotEmpty) &&
        (refresh != null && refresh.isNotEmpty);

    if (!mounted) return;

    if (!loggedIn) {
      setState(() => _screen = const LoginScreen());
      return;
    }

    final rol = JwtUtils.getRole(access!);

    if (rol == 'administrador' || rol == 'bienestar') {
      setState(() => _screen = const AdminDashboard());
    } else {
      setState(() => _screen = const StudentDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _screen!;
  }
}
