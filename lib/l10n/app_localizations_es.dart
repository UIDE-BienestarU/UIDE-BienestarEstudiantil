// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bienestar Estudiantil UIDE';

  @override
  String get loginTitle => 'Iniciar Sesión';

  @override
  String get loginSubtitle => 'Usa tus credenciales de Canvas';

  @override
  String get emailHint => 'usuario@uide.edu.ec';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get loginButton => 'INGRESAR';

  @override
  String get institutionalEmailError => 'Usa tu correo institucional @uide.edu.ec';

  @override
  String get fillFieldsError => 'Completa todos los campos';

  @override
  String get adminPanel => 'Panel Administrativo';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmMessage => '¿Estás seguro de que deseas salir?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exit => 'Salir';

  @override
  String get homeTab => 'Inicio';

  @override
  String get requestsTab => 'Solicitudes';

  @override
  String get newsTab => 'Noticias';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get welcomeAdmin => '¡Hola, Administrador!';

  @override
  String get manageRequests => 'Gestiona todas las solicitudes de los estudiantes';

  @override
  String get pending => 'Pendientes';

  @override
  String get inReview => 'Revisión';

  @override
  String get approved => 'Aprobadas';

  @override
  String get rejected => 'Rechazadas';

  @override
  String get latestRequest => 'Última solicitud';

  @override
  String get noRequestsYet => 'No hay solicitudes aún';

  @override
  String get noPendingRequests => 'No hay solicitudes pendientes';

  @override
  String get errorLoadingStats => 'Error al cargar estadísticas';

  @override
  String get errorLoading => 'Error al cargar';
}
