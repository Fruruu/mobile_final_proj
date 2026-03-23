import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../services/journal_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final JournalService _journalService = JournalService();

  // State
  List<DailyCheckin> _checkins = [];
  List<JournalEntry> _journals = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<DailyCheckin> get checkins => _checkins;
  List<JournalEntry> get journals => _journals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get combined list sorted by date (newest first)
  List<dynamic> getCombinedTimeline() {
    final combined = <dynamic>[];
    combined.addAll(_checkins);
    combined.addAll(_journals);
    
    // Sort by date descending (newest first)
    combined.sort((a, b) {
      final dateA = (a is DailyCheckin) ? a.date : (a as JournalEntry).date;
      final dateB = (b is DailyCheckin) ? b.date : (b as JournalEntry).date;
      return dateB.compareTo(dateA);
    });
    
    return combined;
  }

  // Load both check-ins and journals
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final checkinsResult = _databaseService.getCheckins(userId);
      final journalsResult = _journalService.getJournals(userId);
      
      final results = await Future.wait([checkinsResult, journalsResult]);
      _checkins = results[0] as List<DailyCheckin>;
      _journals = results[1] as List<JournalEntry>;
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a check-in
  Future<void> deleteCheckin(String id, String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _databaseService.deleteCheckin(id);
      await loadHistory(userId);
    } catch (e) {
      _errorMessage = 'Failed to delete check-in: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a journal entry
  Future<void> deleteJournal(String id, String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _journalService.deleteJournal(id);
      await loadHistory(userId);
    } catch (e) {
      _errorMessage = 'Failed to delete journal entry: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to get mood emoji from mood number
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

  // Helper to get mood text
  String getMoodText(int? mood) {
    switch (mood) {
      case 1:
        return 'Anxious';
      case 2:
        return 'Sad';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return 'Unknown';
    }
  }

  // Helper to format date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
