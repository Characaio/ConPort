import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.light;
  bool _useMaterial3 = true;
  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _profilePublic = true;
  bool _allowFriendRequests = true;
  bool _shareLocation = false;
  bool _analytics = true;

  ThemeMode get themeMode => _themeMode;
  bool get useMaterial3 => _useMaterial3;
  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get profilePublic => _profilePublic;
  bool get allowFriendRequests => _allowFriendRequests;
  bool get shareLocation => _shareLocation;
  bool get analytics => _analytics;

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void setUseMaterial3(bool value) {
    if (_useMaterial3 == value) return;
    _useMaterial3 = value;
    notifyListeners();
  }

  void setFontScale(double value) {
    final next = value.clamp(0.85, 1.3).toDouble();
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    if (_highContrast == value) return;
    _highContrast = value;
    notifyListeners();
  }

  void setReduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    if (_emailNotifications == value) return;
    _emailNotifications = value;
    notifyListeners();
  }

  void setProfilePublic(bool value) {
    if (_profilePublic == value) return;
    _profilePublic = value;
    notifyListeners();
  }

  void setAllowFriendRequests(bool value) {
    if (_allowFriendRequests == value) return;
    _allowFriendRequests = value;
    notifyListeners();
  }

  void setShareLocation(bool value) {
    if (_shareLocation == value) return;
    _shareLocation = value;
    notifyListeners();
  }

  void setAnalytics(bool value) {
    if (_analytics == value) return;
    _analytics = value;
    notifyListeners();
  }
}
