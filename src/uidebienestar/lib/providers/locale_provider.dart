import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  void toggleLocale() {
    _locale = _locale.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    notifyListeners();
  }
}
