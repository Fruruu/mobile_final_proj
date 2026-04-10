import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import '../utils/philippine_phone_utils.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(trimmed);
  }

  String _friendlyAuthError(Object error, {required bool isLogin}) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Wrong email or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (message.contains('already registered') ||
        message.contains('user already registered')) {
      return 'This email is already registered. Try signing in.';
    }
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('password should be at least') ||
        message.contains('at least 6')) {
      return 'Password must be at least 6 characters.';
    }
    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }
    if (message.contains('failed host lookup') ||
        message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('timeout')) {
      return 'No internet connection. Please try again.';
    }

    return isLogin
        ? 'Login failed. Please check your credentials and try again.'
        : 'Sign up failed. Please check your details and try again.';
  }

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

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) {
      _errorMessage = 'Email is required.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(trimmedEmail)) {
      _errorMessage = 'Please enter a valid email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (trimmedPassword.isEmpty) {
      _errorMessage = 'Password is required.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (trimmedPassword.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final normalizedPhone = PhilippinePhoneUtils.normalizeMobile(phone);
    if ((phone ?? '').trim().isNotEmpty && normalizedPhone == null) {
      _errorMessage = 'Enter a valid PH mobile number (e.g. +639171234567).';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await _authService.signUp(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      if (response.user != null) {
        // Create or update profile with extra fields
        final profile = UserProfile(
          id: response.user!.id,
          email: trimmedEmail,
          name: name?.trim().isEmpty == true ? null : name,
          birthday: birthday,
          phone: normalizedPhone,
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
      _errorMessage = _friendlyAuthError(e, isLogin: false);
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

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) {
      _errorMessage = 'Email is required.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(trimmedEmail)) {
      _errorMessage = 'Please enter a valid email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (trimmedPassword.isEmpty) {
      _errorMessage = 'Password is required.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await _authService.login(
        email: trimmedEmail,
        password: trimmedPassword,
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
      _errorMessage = _friendlyAuthError(e, isLogin: true);
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