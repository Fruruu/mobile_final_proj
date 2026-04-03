import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // SIGN UP
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
    DateTime? birthday,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create or update profile with extra fields
        final profile = UserProfile(
          id: response.user!.id,
          email: email,
          name: name?.trim().isEmpty == true ? null : name,
          birthday: birthday,
          phone: phone?.trim().isEmpty == true ? null : phone,
        );
        await _profileService.upsertProfile(profile);

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Signup failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}