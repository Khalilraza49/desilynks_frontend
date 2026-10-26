import 'package:flutter/material.dart';

/// Setting item model used to describe a settings row entry.
class SettingItem {
  final String label;
  final String iconBgColorHex;
  final String iconColorHex;
  final String route;

  const SettingItem({
    required this.label,
    required this.iconBgColorHex,
    required this.iconColorHex,
    required this.route,
  });
}

/// ViewModel for the Settings screen.
///
/// Manages:
/// - Dark mode toggle
/// - Selected language
/// - Logout dialog trigger state
class SettingsViewModel extends ChangeNotifier {
  // ──────────────────────────────────────────────────────────────────────────
  // Dark Mode
  // ──────────────────────────────────────────────────────────────────────────
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    // TODO: Persist dark mode preference via StorageService
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Language Selection
  // ──────────────────────────────────────────────────────────────────────────
  static const List<String> availableLanguages = [
    'English',
    'Spanish',
    'Urdu',
    'Hindi',
    'Panjabi',
  ];

  String _selectedLanguage = 'English';
  String get selectedLanguage => _selectedLanguage;

  void selectLanguage(String language) {
    if (_selectedLanguage == language) return;
    _selectedLanguage = language;
    notifyListeners();
    // TODO: Persist language preference via StorageService
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Logout Dialog Trigger
  // ──────────────────────────────────────────────────────────────────────────
  bool _showLogoutDialog = false;
  bool get showLogoutDialog => _showLogoutDialog;

  void requestLogout() {
    _showLogoutDialog = true;
    notifyListeners();
  }

  void cancelLogout() {
    _showLogoutDialog = false;
    notifyListeners();
  }

  void confirmLogout(VoidCallback onLogout) {
    _showLogoutDialog = false;
    notifyListeners();
    onLogout();
  }
}
