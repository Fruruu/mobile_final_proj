import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/database_service.dart';

class InsightViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // State
  DailyCheckin? _todayCheckin;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  DailyCheckin? get todayCheckin => _todayCheckin;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch today's check-in data
  Future<void> loadTodayCheckin(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _todayCheckin = await _databaseService.getTodayCheckin(userId);
    } catch (e) {
      _errorMessage = 'Failed to load check-in data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to get mood emoji
  String getMoodEmoji(String? aiMood) {
    if (aiMood == null) return '😊';
    
    final lowerMood = aiMood.toLowerCase();
    if (lowerMood.contains('happy') || lowerMood.contains('great') || lowerMood.contains('excellent')) {
      return '😄';
    } else if (lowerMood.contains('good') || lowerMood.contains('positive')) {
      return '🙂';
    } else if (lowerMood.contains('neutral') || lowerMood.contains('okay') || lowerMood.contains('normal')) {
      return '😐';
    } else if (lowerMood.contains('sad') || lowerMood.contains('down')) {
      return '😔';
    } else if (lowerMood.contains('anxious') || lowerMood.contains('stressed') || lowerMood.contains('worried')) {
      return '😰';
    }
    return '😊';
  }
}
