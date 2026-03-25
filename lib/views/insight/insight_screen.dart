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
  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _primarySoft = Color(0xFFFFD1DC);
  static const Color _text = Color(0xFF2D2F2F);
  static const Color _muted = Color(0xFF5A5C5C);

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

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Your Insights',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        backgroundColor: _bg,
        foregroundColor: _primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FFD1DC),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22B2E4FB),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // MOOD DETECTED SECTION
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF4F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'MOOD DETECTED',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _getMoodEmoji(),
                    style: const TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _aiMood.isNotEmpty ? _aiMood : 'Analyzing...',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // AI INSIGHT SECTION
            const Text(
              'AI Insight',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8DADA)),
              ),
              child: Text(
                _aiInsight.isNotEmpty ? _aiInsight : 'Loading insight...',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: _text,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // TODAY'S CHECK-IN SUMMARY
            if (vm.todayCheckin != null) ...[
              const Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6FD),
                  borderRadius: BorderRadius.circular(18),
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
              const SizedBox(height: 22),
            ] else if (vm.isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _primary,
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
              const Text(
                'Your Journal Entry',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Journal entry saved and analyzed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF854D0E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],

            // ACTION BUTTONS
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
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
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
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
        ],
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
            fontWeight: FontWeight.w600,
            color: _text,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _primary,
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
