// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UIDE Student Wellness';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Use your Canvas credentials';

  @override
  String get emailHint => 'user@uide.edu.ec';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'SIGN IN';

  @override
  String get institutionalEmailError => 'Use your institutional email @uide.edu.ec';

  @override
  String get fillFieldsError => 'Fill in all fields';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get homeTab => 'Home';

  @override
  String get requestsTab => 'Requests';

  @override
  String get newsTab => 'News';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get welcomeAdmin => 'Hello, Administrator!';

  @override
  String get manageRequests => 'Manage all student requests';

  @override
  String get pending => 'Pending';

  @override
  String get inReview => 'In Review';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get latestRequest => 'Latest request';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get errorLoadingStats => 'Error loading statistics';

  @override
  String get errorLoading => 'Error loading';
}
