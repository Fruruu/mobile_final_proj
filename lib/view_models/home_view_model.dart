import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // State
  DailyCheckin? _todayCheckin;
  int _streakCount = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  DailyCheckin? get todayCheckin => _todayCheckin;
  int get streakCount => _streakCount;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load today's check-in and calculate streak
  Future<void> loadDashboard(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get today's check-in
      _todayCheckin = await _databaseService.getTodayCheckin(userId);

      // Calculate streak
      await _calculateStreak(userId);

    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate consecutive days of check-ins
  Future<void> _calculateStreak(String userId) async {
    try {
      final allCheckins = await _databaseService.getCheckins(userId);

      if (allCheckins.isEmpty) {
        _streakCount = 0;
        return;
      }

      // Sort by date descending (most recent first)
      allCheckins.sort((a, b) => b.date.compareTo(a.date));

      int streak = 0;
      DateTime currentDate = DateTime.now();

      for (final checkin in allCheckins) {
        final checkinDate = DateTime(
          checkin.date.year,
          checkin.date.month,
          checkin.date.day,
        );
        final expectedDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        // If dates match, increment streak
        if (checkinDate == expectedDate) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      _streakCount = streak;
    } catch (e) {
      _streakCount = 0;
    }
  }

  // Get user email
  String getUserEmail() {
    return Supabase.instance.client.auth.currentUser?.email ?? 'User';
  }

  // Get user name (first part of email)
  String getUserName() {
    final email = getUserEmail();
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }

  // Get mood emoji
  String getMoodEmoji(int? mood) {
    switch (mood) {
      case 1:
        return '😰';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😊';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      _errorMessage = 'Failed to logout: $e';
      notifyListeners();
    }
  }
}
