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
      // Run both requests concurrently to reduce home load time.
      final todayFuture = _databaseService.getTodayCheckin(userId);
      final recentFuture = _databaseService.getRecentCheckins(userId);

      _todayCheckin = await todayFuture;
      final recentCheckins = await recentFuture;
      _streakCount = _calculateStreakFromCheckins(recentCheckins);

    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate consecutive days from a date-descending list.
  int _calculateStreakFromCheckins(List<DailyCheckin> checkins) {
    if (checkins.isEmpty) {
      return 0;
    }

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final checkin in checkins) {
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

      // If dates match, increment streak.
      if (checkinDate == expectedDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
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

  // Get top pattern from this week
  Future<String?> getWeekTopPattern(String userId) async {
    try {
      final lastSevenDays = await _databaseService.getLastSevenDays(userId);
      if (lastSevenDays.isEmpty) return null;

      int exerciseCount = 0;
      int goodHydration = 0;
      double totalSleep = 0;
      int positiveModCount = 0;

      for (final checkin in lastSevenDays) {
        if (checkin.exercised) exerciseCount++;
        if (checkin.waterGlasses != null && checkin.waterGlasses! >= 8) goodHydration++;
        if (checkin.sleepHours != null) totalSleep += checkin.sleepHours!;
        if (checkin.userMood != null && checkin.userMood! >= 4) positiveModCount++;
      }

      final avgSleep = lastSevenDays.isNotEmpty 
          ? (totalSleep / lastSevenDays.length).toStringAsFixed(1)
          : '0';

      // Return the strongest pattern
      if (exerciseCount >= 4) {
        return '✨ Consistent exercise - $exerciseCount/7 days';
      } else if (goodHydration >= 4) {
        return '💧 Strong hydration habits - $goodHydration/7 days';
      } else if (positiveModCount >= 4) {
        return '🌟 Positive mood trend - $positiveModCount/7 days';
      } else if (double.parse(avgSleep) >= 7.0) {
        return '😴 Great sleep average - ${avgSleep}h per night';
      }

      return null;
    } catch (e) {
      return null;
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
