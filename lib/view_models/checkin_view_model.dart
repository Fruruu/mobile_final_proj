import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/database_service.dart';
import '../services/claude_service.dart';

class CheckinViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ClaudeService _claudeService = ClaudeService();

  List<DailyCheckin> _checkins = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _success = false;
  String _aiMood = '';
  String _aiInsight = '';

  // Form state
  int _selectedMood = 3;
  double _sleepHours = 7;
  bool _exercised = false;
  int _waterGlasses = 0;

  // Getters
  List<DailyCheckin> get checkins => _checkins;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get success => _success;
  String get aiMood => _aiMood;
  String get aiInsight => _aiInsight;
  int get selectedMood => _selectedMood;
  double get sleepHours => _sleepHours;
  bool get exercised => _exercised;
  int get waterGlasses => _waterGlasses;

  // Form setters
  void setMood(int mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setSleepHours(double hours) {
    _sleepHours = hours;
    notifyListeners();
  }

  void setExercised(bool value) {
    _exercised = value;
    notifyListeners();
  }

  void setWaterGlasses(int glasses) {
    _waterGlasses = glasses;
    notifyListeners();
  }

  // CREATE + AI ANALYSIS
  Future<void> submitCheckin(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _success = false;
    _aiMood = '';
    _aiInsight = '';
    notifyListeners();

    try {
      // STEP 1 - Save check-in to Supabase
      final checkin = DailyCheckin(
        userId: userId,
        date: DateTime.now(),
        userMood: _selectedMood,
        sleepHours: _sleepHours,
        exercised: _exercised,
        waterGlasses: _waterGlasses,
      );
      await _db.insertCheckin(checkin);

      // STEP 2 - Fetch last 7 days (RAG)
      final lastSevenDays = await _db
          .getLastSevenDays(userId);

      // STEP 3 - Build today's summary
      final todayCheckin = _claudeService
          .buildTodayCheckin({
        'user_mood': _selectedMood,
        'sleep_hours': _sleepHours,
        'exercised': _exercised,
        'water_glasses': _waterGlasses,
      });

      // STEP 4 - Build week summary
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

      // STEP 5 - Send to Claude
      // No journal text since this is check-in only
      final result = await _claudeService
          .analyzeJournal(
        journalText: '',
        todayCheckin: todayCheckin,
        weekSummary: weekSummary,
      );

      // STEP 6 - Save AI results back to Supabase
      _aiMood = result['mood']!;
      _aiInsight = result['insight']!;

      // Get the saved checkin and update it
      final todayData = await _db.getTodayCheckin(userId);
      if (todayData != null) {
        await _db.updateCheckinAiResults(
          todayData.id!,
          _aiMood,
          _aiInsight,
        );
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
  Future<void> loadCheckins(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _checkins = await _db.getCheckins(userId);
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE
  Future<void> updateCheckin(DailyCheckin checkin) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateCheckin(checkin);
      await loadCheckins(checkin.userId);

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<void> deleteCheckin(String id, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteCheckin(id);
      await loadCheckins(userId);

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if today's check-in exists
  Future<bool> todayCheckinExists(String userId) async {
    try {
      final existing = await _db.getTodayCheckin(userId);
      return existing != null;
    } catch (e) {
      return false;
    }
  }

  // Reset form
  void resetForm() {
    _selectedMood = 3;
    _sleepHours = 7;
    _exercised = false;
    _waterGlasses = 0;
  }
}