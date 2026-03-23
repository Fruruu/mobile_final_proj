import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/insight_view_model.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  late String _aiMood;
  late String _aiInsight;
  late String _source;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Extract route arguments
      final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;

      _aiMood = args?['aiMood'] ?? '';
      _aiInsight = args?['aiInsight'] ?? '';
      _source = args?['source'] ?? 'checkin';

      // Load today's check-in data
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final vm = Provider.of<InsightViewModel>(context, listen: false);
        vm.loadTodayCheckin(user.id);
      }

      _initialized = true;
    }
  }

  String _getMoodEmoji() {
    return Provider.of<InsightViewModel>(context).getMoodEmoji(_aiMood);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<InsightViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Insights'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MOOD DETECTED SECTION
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _getMoodEmoji(),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Detected Mood',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _aiMood.isNotEmpty ? _aiMood : 'Analyzing...',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI INSIGHT SECTION
            Text(
              'AI Insight',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Text(
                _aiInsight.isNotEmpty ? _aiInsight : 'Loading insight...',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // TODAY'S CHECK-IN SUMMARY
            if (vm.todayCheckin != null) ...[
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckinItem(
                      '😊 Your Mood',
                      _getMoodNumberEmoji(vm.todayCheckin!.userMood),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckinItem(
                      '😴 Sleep',
                      '${vm.todayCheckin!.sleepHours?.toStringAsFixed(1) ?? 0} hours',
                    ),
                    const SizedBox(height: 12),
                    _buildCheckinItem(
                      '💪 Exercise',
                      vm.todayCheckin!.exercised ? 'Yes' : 'No',
                    ),
                    const SizedBox(height: 12),
                    _buildCheckinItem(
                      '💧 Water',
                      '${vm.todayCheckin!.waterGlasses ?? 0} glasses',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ] else if (vm.isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                ),
              )
            else if (vm.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not load check-in data',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

            // JOURNAL TEXT (if source is journal)
            if (_source == 'journal') ...[
              Text(
                'Your Journal Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200,
                  ),
                ),
                child: Text(
                  'Journal entry saved and analyzed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ACTION BUTTONS
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  String _getMoodNumberEmoji(int? mood) {
    switch (mood) {
      case 1:
        return '😰 (1/5)';
      case 2:
        return '😔 (2/5)';
      case 3:
        return '😐 (3/5)';
      case 4:
        return '🙂 (4/5)';
      case 5:
        return '😄 (5/5)';
      default:
        return 'Not set';
    }
  }
}
