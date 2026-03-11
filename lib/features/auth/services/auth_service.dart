import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provides the current Auth state (true if logged in)
final authStateProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  static const String _authKey = 'is_logged_in';

  @override
  bool build() {
    _loadAuthState();
    return false;
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_authKey) ?? false;
  }

  Future<void> loginWithGoogleMock() async {
    // Simulate network delay for Google Sign-In
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    state = true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    state = false;
  }
}
