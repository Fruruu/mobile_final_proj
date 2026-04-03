import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/claude_service.dart';
import '../services/database_service.dart';
import '../services/profile_service.dart';

class JournalViewModel extends ChangeNotifier {
  final JournalService _journalService = JournalService();
  final ClaudeService _claudeService = ClaudeService();
  final DatabaseService _databaseService = DatabaseService();
  final ProfileService _profileService = ProfileService();

  List<JournalEntry> _journals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _success = false;
  String _aiMood = '';
  String _aiInsight = '';

  // Form state
  String _journalText = '';

  // Getters
  List<JournalEntry> get journals => _journals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get success => _success;
  String get journalText => _journalText;
  String get aiMood => _aiMood;
  String get aiInsight => _aiInsight;

  // Setter
  void setJournalText(String text) {
    _journalText = text;
    notifyListeners();
  }

  // CREATE + AI ANALYSIS
  Future<void> submitJournal(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _success = false;
    _aiMood = '';
    _aiInsight = '';
    notifyListeners();

    try {
      // STEP 1 - Save journal to Supabase
      final entry = JournalEntry(
        userId: userId,
        date: DateTime.now(),
        journalText: _journalText,
      );
      await _journalService.insertJournal(entry);

      // STEP 2 - Fetch today's check-in
      final todayCheckin = await _databaseService
          .getTodayCheckin(userId);

      // STEP 3 - Fetch last 7 days (RAG)
      final lastSevenDays = await _databaseService
          .getLastSevenDays(userId);

      // STEP 4 - Build today's summary
      final todayCheckinSummary = _claudeService
          .buildTodayCheckin(
        todayCheckin != null ? {
          'user_mood': todayCheckin.userMood,
          'sleep_hours': todayCheckin.sleepHours,
          'exercised': todayCheckin.exercised,
          'water_glasses': todayCheckin.waterGlasses,
        } : null,
      );

      // STEP 5 - Build week summary
      final weekSummary = _claudeService
          .buildWeekSummary(
        lastSevenDays.map((e) => {
          'date': e.date.toString().split(' ')[0],
          'user_mood': e.userMood,
          'sleep_hours': e.sleepHours,
          'exercised': e.exercised,
          'water_glasses': e.waterGlasses,
        }).toList(),
      );

      // STEP 6 - Get user's profile for personalization (name, age)
      String? userName;
      int? userAge;
      try {
        final profile = await _profileService.getProfile(userId);
        userName = profile?.name;
        // Calculate age from birthday
        if (profile?.birthday != null) {
          final now = DateTime.now();
          int age = now.year - profile!.birthday!.year;
          if (now.month < profile.birthday!.month ||
              (now.month == profile.birthday!.month &&
                  now.day < profile.birthday!.day)) {
            age--;
          }
          if (age > 0) userAge = age;
        }
      } catch (e) {
        // If profile fetch fails, proceed without personalization
      }

      // STEP 7 - Calculate streak
      int streakCount = 0;
      try {
        final allCheckins = await _databaseService.getCheckins(userId);
        if (allCheckins.isNotEmpty) {
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
            if (checkinDate == expectedDate) {
              streak++;
              currentDate = currentDate.subtract(const Duration(days: 1));
            } else {
              break;
            }
          }
          streakCount = streak;
        }
      } catch (e) {
        streakCount = 0;
      }

      // STEP 8 - Calculate top pattern from week
      String? topPattern;
      try {
        if (lastSevenDays.isNotEmpty) {
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

          if (exerciseCount >= 4) {
            topPattern = '✨ Consistent exercise - $exerciseCount/7 days';
          } else if (goodHydration >= 4) {
            topPattern = '💧 Strong hydration habits - $goodHydration/7 days';
          } else if (positiveModCount >= 4) {
            topPattern = '🌟 Positive mood trend - $positiveModCount/7 days';
          } else if (lastSevenDays.isNotEmpty && totalSleep / lastSevenDays.length >= 7.0) {
            final avgSleep = (totalSleep / lastSevenDays.length).toStringAsFixed(1);
            topPattern = '😴 Great sleep average - ${avgSleep}h per night';
          }
        }
      } catch (e) {
        topPattern = null;
      }
      final result = await _claudeService
          .analyzeJournal(
        journalText: _journalText,
        todayCheckin: todayCheckinSummary,
        weekSummary: weekSummary,
        userName: userName,
        age: userAge,
        topPattern: topPattern,
        streakCount: streakCount,
      );

      // STEP 9 - Save AI results back to Supabase
      _aiMood = result['mood']!;
      _aiInsight = result['insight']!;

      final journals = await _journalService
          .getJournals(userId);
      if (journals.isNotEmpty) {
        final savedEntry = journals.first;
        final updatedEntry = JournalEntry(
          id: savedEntry.id,
          userId: userId,
          date: savedEntry.date,
          journalText: _journalText,
          aiMood: _aiMood,
          aiInsight: _aiInsight,
        );
        await _journalService.updateJournal(updatedEntry);
      }

      _success = true;
      _isLoading = false;
      resetForm();
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // READ
  Future<void> loadJournals(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _journals = await _journalService
          .getJournals(userId);
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE
  Future<void> updateJournal(JournalEntry entry) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _journalService.updateJournal(entry);
      await loadJournals(entry.userId);

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<void> deleteJournal(
      String id, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _journalService.deleteJournal(id);
      await loadJournals(userId);

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if today's journal entry exists
  Future<bool> todayJournalExists(String userId) async {
    try {
      final journals = await _journalService.getJournals(userId);
      final today = DateTime.now()
          .toIso8601String()
          .split('T')[0];

      return journals.any((entry) =>
          entry.date.toIso8601String().split('T')[0] ==
          today);
    } catch (e) {
      return false;
    }
  }

  // Reset form
  void resetForm() {
    _journalText = '';
  }
}