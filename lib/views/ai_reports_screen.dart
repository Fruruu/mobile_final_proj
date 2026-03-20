import 'package:flutter/material.dart';

final Map<String, int> _moodData = {
  _key(DateTime.now().subtract(const Duration(days: 10))): 3,
  _key(DateTime.now().subtract(const Duration(days: 9))): 2,
  _key(DateTime.now().subtract(const Duration(days: 8))): 3,
  _key(DateTime.now().subtract(const Duration(days: 7))): 1,
  _key(DateTime.now().subtract(const Duration(days: 6))): 3,
  _key(DateTime.now().subtract(const Duration(days: 5))): 2,
  _key(DateTime.now().subtract(const Duration(days: 4))): 3,
  _key(DateTime.now().subtract(const Duration(days: 3))): 3,
  _key(DateTime.now().subtract(const Duration(days: 2))): 2,
  _key(DateTime.now().subtract(const Duration(days: 1))): 3,
};

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class CalendarTracker extends StatefulWidget {
  const CalendarTracker({super.key});

  @override
  State<CalendarTracker> createState() => _CalendarTrackerState();
}

class _CalendarTrackerState extends State<CalendarTracker> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  int _startWeekday(DateTime month) {
    final wd = DateTime(month.year, month.month, 1).weekday;
    return wd % 7;
  }

  Color _moodColor(DateTime day) {
    final mood = _moodData[_key(day)] ?? 0;
    return switch (mood) {
      1 => const Color(0xFFEF5350),
      2 => const Color(0xFFFFA726),
      3 => const Color(0xFF66BB6A),
      _ => const Color(0xFFE0E0E0),
    };
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  bool _isFuture(DateTime day) => day.isAfter(DateTime.now());

  void _prevMonth() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));

  void _nextMonth() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  void _showMoodPicker(DateTime day) {
    if (_isFuture(day)) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.deepPurple[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How was ${_monthName(_viewMonth.month)} ${day.day}?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _moodButton(day, 1, '😞', 'Poor', const Color(0xFFEF5350)),
                _moodButton(day, 2, '😐', 'Okay', const Color(0xFFFFA726)),
                _moodButton(day, 3, '😊', 'Good', const Color(0xFF66BB6A)),
              ],
            ),
            const SizedBox(height: 12),
            if (_moodData.containsKey(_key(day)))
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                label: const Text('Clear entry', style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  setState(() => _moodData.remove(_key(day)));
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _moodButton(DateTime day, int level, String emoji, String label, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() => _moodData[_key(day)] = level);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  @override
  Widget build(BuildContext context) {
    final startOffset = _startWeekday(_viewMonth);
    final daysInMonth = _daysInMonth(_viewMonth);
    final totalCells = (((startOffset + daysInMonth) / 7).ceil()) * 7;

    return Card(
      color: Colors.deepPurple[50],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mood Calendar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
                      onPressed: _prevMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_monthName(_viewMonth.month)} ${_viewMonth.year}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                      onPressed: _nextMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => SizedBox(
                        width: 32,
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple[300]),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final dayNumber = index - startOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox.shrink();
                final day = DateTime(_viewMonth.year, _viewMonth.month, dayNumber);
                final isToday = _isToday(day);
                final future = _isFuture(day);
                return GestureDetector(
                  onTap: () => _showMoodPicker(day),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: future ? Colors.transparent : _moodColor(day),
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: Colors.deepPurple, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: future ? Colors.grey[400] : Colors.white,
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(const Color(0xFF66BB6A), 'Good'),
                const SizedBox(width: 12),
                _legend(const Color(0xFFFFA726), 'Okay'),
                const SizedBox(width: 12),
                _legend(const Color(0xFFEF5350), 'Poor'),
                const SizedBox(width: 12),
                _legend(const Color(0xFFE0E0E0), 'None'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      );
}

class AIReportsScreen extends StatelessWidget {
  const AIReportsScreen({super.key});

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }

  int _countMood(int level) {
    final now = DateTime.now();
    return _moodData.entries.where((e) {
      final parts = e.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return year == now.year && month == now.month && e.value == level;
    }).length;
  }

  String _trendLabel() {
    final good = _countMood(3);
    final poor = _countMood(1);
    if (good > poor + 2) return 'Trending up 📈';
    if (poor > good + 2) return 'Needs attention 📉';
    return 'Stable 📊';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Mood Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const CalendarTracker(),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('Mood Trend', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(_trendLabel(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Good Days', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${_countMood(3)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF66BB6A))),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Poor Days', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${_countMood(1)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF5350))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.deepPurple),
                  title: Text('Insight ${index + 1}'),
                  subtitle: const Text('Your sleep patterns correlate with better mood days.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Progress Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _statCard('Mood Streak', '4 days', Icons.emoji_emotions, Colors.green),
                _statCard('Sleep Goal', '80%', Icons.nights_stay, Colors.blue),
                _statCard('Exercise', '5/7 days', Icons.fitness_center, Colors.orange),
                _statCard('Water', '28 glasses', Icons.local_drink, Colors.cyan),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Mood Trend (Week)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📈 Chart Placeholder\n(Line chart showing mood progression)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sleep Hours Trend', style: TextStyle(fontSize: 18)),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📊 Bar chart placeholder', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
