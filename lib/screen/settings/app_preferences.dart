import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences(this._storage)
    : isTamil =
          (_storage.getString('app_language') ??
              _storage.getString('policy_language')) ==
          'ta',
      isDark = _storage.getBool('dark_theme') ?? false;

  final SharedPreferences _storage;
  bool isTamil;
  bool isDark;
  Future<void> _pendingSave = Future<void>.value();

  String text(String english, String tamil) => isTamil ? tamil : english;

  Future<void> setLanguage(bool tamil) {
    isTamil = tamil;
    notifyListeners();
    return _save('app_language', tamil ? 'ta' : 'en');
  }

  Future<void> setDark(bool dark) {
    isDark = dark;
    notifyListeners();
    return _save('dark_theme', dark);
  }

  Future<void> _save(String key, Object value) {
    final save = _pendingSave.then((_) async {
      final saved = value is bool
          ? await _storage.setBool(key, value)
          : await _storage.setString(key, value as String);
      if (!saved) throw StateError('Could not save preferences');
    });
    _pendingSave = save.catchError((Object _) {});
    return save;
  }
}
