import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/insight_view_model.dart';
import '../../widgets/auth_visuals.dart';
import '../../widgets/frosted_app_bar.dart';
import '../../theme/app_colors.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  static const Color _bg = AppColors.white;
  static const Color _primary = AppColors.primaryPink;
  static const Color _primarySoft = Color(0x33FF6169);
  static const Color _text = AppColors.black;
  static const Color _muted = AppColors.black;

  late String _aiMood;
  late String _aiInsight;
  late String _source;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Extract route arguments
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<InsightViewModel>(context);

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: 'Your Insights',
        showBackButton: true,
        onBackPressed: () =>
            Navigator.pushReplacementNamed(context, '/history'),
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
                color: Color(0x26FF6169),
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
                color: Color(0x334EC1F5),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + FrostedAppBar.barHeight + 8,
              20,
              24,
            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
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
                      SvgPicture.asset(
                        _getMoodAssetForAiMood(_aiMood),
                        width: 86,
                        height: 86,
                        fit: BoxFit.contain,
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
                      color: const Color(0x334EC1F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMoodCheckinItem(vm.todayCheckin!.userMood),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Sleep',
                          '${vm.todayCheckin!.sleepHours?.toStringAsFixed(1) ?? 0} hours',
                        ),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Exercise',
                          vm.todayCheckin!.exercised ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Water',
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
                      child: AnimatedMoodPathLogo(
                        size: 68,
                        iconSize: 58,
                        interval: Duration(milliseconds: 1200),
                      ),
                    ),
                  )
                else if (vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Could not load check-in data',
                      style: TextStyle(color: AppColors.red, fontSize: 14),
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
                      color: const Color(0x55FFDE71),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Journal entry saved and analyzed',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.orange,
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
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    'View Entries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildMoodCheckinItem(int? mood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Mood',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _text,
          ),
        ),
        Row(
          children: [
            SvgPicture.asset(
              _getMoodAssetForNumber(mood),
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              _getMoodScoreText(mood),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMoodScoreText(int? mood) {
    switch (mood) {
      case 1:
        return '1/5';
      case 2:
        return '2/5';
      case 3:
        return '3/5';
      case 4:
        return '4/5';
      case 5:
        return '5/5';
      default:
        return 'Not set';
    }
  }

  String _getMoodAssetForNumber(int? mood) {
    switch (mood) {
      case 5:
        return 'assets/logos/very-happy-face.svg';
      case 4:
        return 'assets/logos/happy-face.svg';
      case 3:
        return 'assets/logos/neutral-face.svg';
      case 2:
        return 'assets/logos/sad-face.svg';
      case 1:
        return 'assets/logos/very-sad-face.svg';
      default:
        return 'assets/logos/neutral-face.svg';
    }
  }

  String _getMoodAssetForAiMood(String? aiMood) {
    if (aiMood == null || aiMood.trim().isEmpty) {
      return 'assets/logos/neutral-face.svg';
    }

    final lower = aiMood.toLowerCase();
    if (lower.contains('great') ||
        lower.contains('radiant') ||
        lower.contains('excellent') ||
        lower.contains('very happy')) {
      return 'assets/logos/very-happy-face.svg';
    }
    if (lower.contains('good') ||
        lower.contains('calm') ||
        lower.contains('positive') ||
        lower.contains('happy')) {
      return 'assets/logos/happy-face.svg';
    }
    if (lower.contains('neutral') ||
        lower.contains('okay') ||
        lower.contains('normal') ||
        lower.contains('steady')) {
      return 'assets/logos/neutral-face.svg';
    }
    if (lower.contains('sad') ||
        lower.contains('down') ||
        lower.contains('bad') ||
        lower.contains('heavy')) {
      return 'assets/logos/sad-face.svg';
    }
    if (lower.contains('anxious') ||
        lower.contains('stressed') ||
        lower.contains('worried') ||
        lower.contains('fragile') ||
        lower.contains('very low')) {
      return 'assets/logos/very-sad-face.svg';
    }

    return 'assets/logos/neutral-face.svg';
  }
}