import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/database_service.dart';

class CheckinViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<DailyCheckin> _checkins = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _success = false;

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

  // CREATE
  Future<void> submitCheckin(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _success = false;
    notifyListeners();

    try {
      final checkin = DailyCheckin(
        userId: userId,
        date: DateTime.now(),
        userMood: _selectedMood,
        sleepHours: _sleepHours,
        exercised: _exercised,
        waterGlasses: _waterGlasses,
      );

      await _db.insertCheckin(checkin);

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

  // Reset form after submit
  void resetForm() {
    _selectedMood = 3;
    _sleepHours = 7;
    _exercised = false;
    _waterGlasses = 0;
  }
}