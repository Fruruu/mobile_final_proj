import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/database_service.dart';
import '../services/claude_service.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ClaudeService _claudeService = ClaudeService();

  // State
  List<DailyCheckin> _weeklyCheckins = [];
  List<DailyCheckin> _monthlyCheckins = [];
  String _selectedView = 'weekly'; // 'weekly' or 'monthly'
  
  // Analysis data
  Map<int, int> _moodFrequency = {}; // mood level -> count
  double _averageMood = 0;
  double _averageSleep = 0;
  int _exerciseCount = 0;
  double _averageWater = 0;
  
  // Habit-mood correlation
  double _moodWithExercise = 0;
  double _moodWithoutExercise = 0;
  double _moodWithGoodSleep = 0;
  double _moodWithPoorSleep = 0;
  
  String _insightText = '';
  final Map<String, String> _insightByView = {
    'weekly': '',
    'monthly': '',
  };
  final Map<String, String> _insightSignatureByView = {
    'weekly': '',
    'monthly': '',
  };
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<DailyCheckin> get checkins => _selectedView == 'weekly' ? _weeklyCheckins : _monthlyCheckins;
  String get selectedView => _selectedView;
  
  Map<int, int> get moodFrequency => _moodFrequency;
  double get averageMood => _averageMood;
  double get averageSleep => _averageSleep;
  int get exerciseCount => _exerciseCount;
  double get averageWater => _averageWater;
  
  double get moodWithExercise => _moodWithExercise;
  double get moodWithoutExercise => _moodWithoutExercise;
  double get moodWithGoodSleep => _moodWithGoodSleep;
  double get moodWithPoorSleep => _moodWithPoorSleep;
  
  String get insightText => _insightText;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load reports
  Future<void> loadReports(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Load both weekly and monthly data
      final weekly = await _databaseService.getLastSevenDays(userId);
      final monthly = await _databaseService.getLastThirtyDays(userId);

      _weeklyCheckins = weekly;
      _monthlyCheckins = monthly;

      // Generate insight only when view data has changed.
      await _refreshInsightIfNeededForView('weekly', userId);
      await _refreshInsightIfNeededForView('monthly', userId);

      // Apply selected view snapshot for UI.
      _applySelectedViewSnapshot();

    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Switch between weekly and monthly view
  void switchView(String view) {
    if (view != _selectedView) {
      _selectedView = view;

      // Switches should be instant and should not trigger a fresh AI prompt.
      _applySelectedViewSnapshot();
      notifyListeners();
    }
  }

  // Analyze data and generate insight
  Future<void> _analyzeAndGenerateInsight(String userId) async {
    final data = checkins;

    if (data.isEmpty) {
      _insightText = 'No data available for this period. Start tracking your mood!';
      return;
    }

    // Calculate mood frequency
    _calculateMoodFrequency(data);

    // Calculate averages
    _calculateAverages(data);

    // Calculate habit-mood correlation
    _calculateHabitCorrelation(data);

    // Generate Claude insight
    await _generateClaudeInsight(userId);
  }

  Future<void> _refreshInsightIfNeededForView(String view, String userId) async {
    final previousView = _selectedView;
    _selectedView = view;

    final data = checkins;
    final signature = _buildDataSignature(data);

    if (data.isEmpty) {
      _insightByView[view] = 'No data available for this period. Start tracking your mood!';
      _insightSignatureByView[view] = signature;
      _selectedView = previousView;
      return;
    }

    _calculateMoodFrequency(data);
    _calculateAverages(data);
    _calculateHabitCorrelation(data);

    final cachedSignature = _insightSignatureByView[view] ?? '';
    final cachedInsight = _insightByView[view] ?? '';

    if (signature != cachedSignature || cachedInsight.isEmpty) {
      await _generateClaudeInsight(userId);
      _insightByView[view] = _insightText;
      _insightSignatureByView[view] = signature;
    } else {
      _insightText = cachedInsight;
    }

    _selectedView = previousView;
  }

  void _applySelectedViewSnapshot() {
    final data = checkins;

    if (data.isEmpty) {
      _moodFrequency = {};
      _averageMood = 0;
      _averageSleep = 0;
      _exerciseCount = 0;
      _averageWater = 0;
      _moodWithExercise = 0;
      _moodWithoutExercise = 0;
      _moodWithGoodSleep = 0;
      _moodWithPoorSleep = 0;
      _insightText = 'No data available for this period. Start tracking your mood!';
      return;
    }

    _calculateMoodFrequency(data);
    _calculateAverages(data);
    _calculateHabitCorrelation(data);

    _insightText = _insightByView[_selectedView] ?? '';
    if (_insightText.isEmpty) {
      _insightText = 'Insight will refresh after your next check-in update.';
    }
  }

  String _buildDataSignature(List<DailyCheckin> data) {
    if (data.isEmpty) {
      return 'empty';
    }

    final normalized = data.map((checkin) {
      final date = checkin.date.toIso8601String().split('T')[0];
      final mood = checkin.userMood?.toString() ?? 'n';
      final sleep = checkin.sleepHours?.toStringAsFixed(1) ?? 'n';
      final exercised = checkin.exercised ? '1' : '0';
      final water = checkin.waterGlasses?.toString() ?? 'n';
      final createdAt = checkin.createdAt ?? '';
      return '$date:$mood:$sleep:$exercised:$water:$createdAt';
    }).toList()
      ..sort();

    return normalized.join('|');
  }

  // Calculate mood frequency distribution
  void _calculateMoodFrequency(List<DailyCheckin> data) {
    _moodFrequency = {};
    int totalMood = 0;

    for (final checkin in data) {
      if (checkin.userMood != null) {
        _moodFrequency[checkin.userMood!] = (_moodFrequency[checkin.userMood!] ?? 0) + 1;
        totalMood += checkin.userMood!;
      }
    }

    final count = data.where((c) => c.userMood != null).length;
    _averageMood = count > 0 ? totalMood / count : 0;
  }

  // Calculate average metrics
  void _calculateAverages(List<DailyCheckin> data) {
    double totalSleep = 0;
    int sleepCount = 0;
    int totalWater = 0;
    int waterCount = 0;

    _exerciseCount = 0;

    for (final checkin in data) {
      if (checkin.sleepHours != null) {
        totalSleep += checkin.sleepHours!;
        sleepCount++;
      }
      if (checkin.waterGlasses != null) {
        totalWater += checkin.waterGlasses!;
        waterCount++;
      }
      if (checkin.exercised) {
        _exerciseCount++;
      }
    }

    _averageSleep = sleepCount > 0 ? totalSleep / sleepCount : 0;
    _averageWater = waterCount > 0 ? totalWater / waterCount : 0;
  }

  // Calculate habit-mood correlation
  void _calculateHabitCorrelation(List<DailyCheckin> data) {
    // Mood with exercise
    int moodWithExerciseSum = 0;
    int withExerciseCount = 0;
    int moodWithoutExerciseSum = 0;
    int withoutExerciseCount = 0;

    // Mood with good sleep (7+ hours)
    int moodWithGoodSleepSum = 0;
    int goodSleepCount = 0;
    int moodWithPoorSleepSum = 0;
    int poorSleepCount = 0;

    for (final checkin in data) {
      if (checkin.userMood != null) {
        // Exercise correlation
        if (checkin.exercised) {
          moodWithExerciseSum += checkin.userMood!;
          withExerciseCount++;
        } else {
          moodWithoutExerciseSum += checkin.userMood!;
          withoutExerciseCount++;
        }

        // Sleep correlation
        if (checkin.sleepHours != null) {
          if (checkin.sleepHours! >= 7) {
            moodWithGoodSleepSum += checkin.userMood!;
            goodSleepCount++;
          } else {
            moodWithPoorSleepSum += checkin.userMood!;
            poorSleepCount++;
          }
        }
      }
    }

    _moodWithExercise = withExerciseCount > 0 ? moodWithExerciseSum / withExerciseCount : 0;
    _moodWithoutExercise = withoutExerciseCount > 0 ? moodWithoutExerciseSum / withoutExerciseCount : 0;
    _moodWithGoodSleep = goodSleepCount > 0 ? moodWithGoodSleepSum / goodSleepCount : 0;
    _moodWithPoorSleep = poorSleepCount > 0 ? moodWithPoorSleepSum / poorSleepCount : 0;
  }

  // Generate insight using Claude RAG
  Future<void> _generateClaudeInsight(String userId) async {
    try {
      final period = _selectedView == 'weekly' ? 'last week' : 'last month';
      final data = checkins;

      // Build context for Claude
      final moodList = data
          .where((c) => c.userMood != null)
          .map((c) => _getMoodLabel(c.userMood!))
          .toList();

      final moodDistribution = moodList.isEmpty 
          ? 'No mood data available'
          : 'Mood distribution: ${_moodFrequency.entries.map((e) => '${_getMoodLabel(e.key)} (${e.value}x)').join(", ")}';

      final exerciseInsight = _exerciseCount == 0
          ? 'Did not exercise'
          : 'Exercised ${_exerciseCount} times (avg mood with exercise: ${_moodWithExercise.toStringAsFixed(1)})';

      final sleepInsight = 'Average sleep: ${_averageSleep.toStringAsFixed(1)} hours';

      final context = '''
Analyze this mood tracking data from the $period:
- $moodDistribution
- Average mood: ${_averageMood.toStringAsFixed(1)}/5
- $exerciseInsight
- $sleepInsight
- Average water: ${_averageWater.toStringAsFixed(1)} glasses

Provide a brief, encouraging insight about their mood patterns and habits.
''';

      final insight = await _claudeService.generateWithContext(
        'moodtracker',
        context,
        data,
      );

      _insightText = insight;
    } catch (e) {
      _insightText = 'Could not generate AI insight. View your stats above!';
    }
  }

  // Helper: Get mood label from number
  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
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

  // Helper: Get mood emoji
  String getMoodEmoji(int mood) {
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
}
