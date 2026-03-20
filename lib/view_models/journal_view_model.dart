import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';

class JournalViewModel extends ChangeNotifier {
  final JournalService _journalService = JournalService();

  List<JournalEntry> _journals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _success = false;

  // Form state
  String _journalText = '';

  // Getters
  List<JournalEntry> get journals => _journals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get success => _success;
  String get journalText => _journalText;

  // Setter
  void setJournalText(String text) {
    _journalText = text;
    notifyListeners();
  }

  // CREATE
  Future<void> submitJournal(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _success = false;
    notifyListeners();

    try {
      final entry = JournalEntry(
        userId: userId,
        date: DateTime.now(),
        journalText: _journalText,
      );

      await _journalService.insertJournal(entry);

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
      _journals = await _journalService.getJournals(userId);
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
  Future<void> deleteJournal(String id, String userId) async {
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

  // Reset form
  void resetForm() {
    _journalText = '';
  }
}