import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  // Make it accessible to views
  ProfileService get profileService => _profileService;

  UserProfile? _profile;
  bool _isLoading = false;
  String _errorMessage = '';

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get user's display name (name if set, otherwise extract from email)
  String getDisplayName() {
    if (_profile?.name != null && _profile!.name!.isNotEmpty) {
      return _profile!.name!;
    }
    // Fallback: extract name from email
    final email = _profile?.email ?? '';
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return 'User';
  }

  // Calculate age from birthday
  int? getAge() {
    if (_profile?.birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - _profile!.birthday!.year;
    if (now.month < _profile!.birthday!.month ||
        (now.month == _profile!.birthday!.month &&
            now.day < _profile!.birthday!.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }

  // Load profile
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final userProfile = await _profileService.getProfile(userId);
      _profile = userProfile;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
