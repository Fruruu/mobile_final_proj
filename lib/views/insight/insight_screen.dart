import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  late String _journalText;
  Map<String, dynamic>? _checkinData;
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
      _journalText = args?['journalText'] ?? '';
        final rawCheckinData = args?['checkinData'];
        _checkinData = rawCheckinData is Map<String, dynamic>
          ? rawCheckinData
          : (rawCheckinData is Map
            ? Map<String, dynamic>.from(rawCheckinData)
            : null);


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
    final fallbackMood = _checkinData?['user_mood'] as int?;
    final fallbackSleep = (_checkinData?['sleep_hours'] as num?)?.toDouble();
    final fallbackExercised = _checkinData?['exercised'] as bool?;
    final fallbackWater = _checkinData?['water_glasses'] as int?;
    final hasFallbackCheckin = _checkinData != null;

    final summaryMood = vm.todayCheckin?.userMood ?? fallbackMood;
    final summarySleep = vm.todayCheckin?.sleepHours ?? fallbackSleep;
    final summaryExercised = vm.todayCheckin?.exercised ?? fallbackExercised;
    final summaryWater = vm.todayCheckin?.waterGlasses ?? fallbackWater;

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
                if (_source != 'journal') ...[
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
                ],

                // JOURNAL TEXT FIRST (if source is journal)
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE8E3DC).withOpacity(0.75),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8E3DC).withOpacity(0.75),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _PaperLinesPainter(),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 2,
                              margin: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(minHeight: 90),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.42),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _journalText.isNotEmpty
                                    ? _journalText
                                    : 'No journal text available',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _text,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // AI INSIGHT SECTION (now after journal)
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
                  child: MarkdownBody(
                    data: _aiInsight.isNotEmpty
                        ? _aiInsight
                        : 'Loading insight...',
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: _text,
                      ),
                      h1: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                      h2: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 15,
                        color: _text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // TODAY'S CHECK-IN SUMMARY
                if (_source != 'journal' &&
                    (vm.todayCheckin != null || hasFallbackCheckin)) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Summary",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFF6169),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0x33FF6169),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _getMoodEmojiFromNumber(summaryMood),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getMoodScoreText(summaryMood),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        _buildMoodCheckinItem(summaryMood),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Sleep',
                          '${(summarySleep ?? 0).toStringAsFixed(1)} hours',
                        ),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Exercise',
                          (summaryExercised ?? false) ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 12),
                        _buildCheckinItem(
                          'Water',
                          '${summaryWater ?? 0} glasses',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ] else if (_source != 'journal' && vm.isLoading)
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
                else if (_source != 'journal' && vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Could not load check-in data',
                      style: TextStyle(color: AppColors.red, fontSize: 14),
                    ),
                  ),

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

  String _getMoodEmojiFromNumber(int? mood) {
    switch (mood) {
      case 5:
        return '😄';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😔';
      case 1:
        return '😰';
      default:
        return '😊';
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

class _PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A8F8B8C)
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (double y = 14; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}