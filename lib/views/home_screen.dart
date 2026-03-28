  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:provider/provider.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../view_models/home_view_model.dart';
  import '../widgets/app_bottom_nav.dart';
  import '../widgets/check_list_item_card.dart';
  import '../widgets/frosted_app_bar.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    bool _initialized = false;

    static const Color _surface = Color(0xFFF4EFF1);
    static const Color _pink = Color(0xFFFF6169);
    static const Color _black = Color(0xFF231F20);
    static const Color _yellow = Color(0xFFFFDE71);
    static const Color _orange = Color(0xFFFF9800);
    static const Color _blue = Color(0xFF4EC1F5);
    static const Color _green = Color(0xFFC3FFA7);
    static const Color _darkGreen = Color(0xFF3AB500);
    static const Color _white = Color(0xFFFFFFFF);

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();

      if (!_initialized) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final vm = Provider.of<HomeViewModel>(context, listen: false);
          vm.loadDashboard(user.id);
        }
        _initialized = true;
      }
    }

    @override
    Widget build(BuildContext context) {
      final vm = Provider.of<HomeViewModel>(context);
      final today = vm.todayCheckin;
      final hasCheckin = today != null;
      final userName = _formatName(vm.getUserName());
      final hydrationCount = today?.waterGlasses ?? 0;
      final hydrationCompleted = hydrationCount >= 8;
      final streakCount = vm.streakCount;
      final currentMood = vm.getMoodEmoji(today?.userMood);
      final sleepHours = today?.sleepHours ?? 0;
      final exercised = today?.exercised ?? false;

      return Scaffold(
        backgroundColor: _surface,
        extendBodyBehindAppBar: true,
        appBar: const FrostedAppBar(title: 'Mood Path'),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(
                context: context,
                userName: userName,
                hydrationCount: hydrationCount,
                streakCount: streakCount,
                moodEmoji: currentMood,
                hasCheckin: hasCheckin,
                topOffset:
                    MediaQuery.of(context).padding.top + FrostedAppBar.barHeight,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Snapshot',
                      style: TextStyle(
                        fontSize: 22,
                        color: _black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSnapshotCard(
                      hasCheckin: hasCheckin,
                      moodEmoji: currentMood,
                      sleepHours: sleepHours,
                      exercised: exercised,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Daily Check List',
                      style: TextStyle(
                        fontSize: 22,
                        color: _black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckListItemCard(
                      leading: '💧',
                      title: 'Drink Water',
                      subtitle: '$hydrationCount/8 Glasses of water drank today.',
                      startColor: _white.withOpacity(0.22),
                      endColor: _blue,
                      isCompleted: hydrationCompleted,
                      onTap: () => Navigator.pushNamed(context, '/checkin'),
                    ),
                    const SizedBox(height: 12),
                    CheckListItemCard(
                      leading: '🏁',
                      title: 'Daily Check-In',
                      subtitle: hasCheckin
                          ? 'You already completed your daily check-in today.'
                          : 'You still haven\'t done your daily check-in today.',
                      startColor: _white.withOpacity(0.22),
                      endColor: _green.withOpacity(0.96),
                      isCompleted: hasCheckin,
                      onTap: () => Navigator.pushNamed(context, '/checkin'),
                    ),
                    const SizedBox(height: 12),
                    CheckListItemCard(
                      leading: '📝',
                      title: 'Journal',
                      subtitle: 'Take a minute to write what you feel today.',
                      startColor: _white.withOpacity(0.22),
                      endColor: _orange.withOpacity(0.9),
                      onTap: () => Navigator.pushNamed(context, '/journal'),
                    ),
                    const SizedBox(height: 12),
                    CheckListItemCard(
                      leading: '📈',
                      title: 'Review History',
                      subtitle: 'See your mood trend and progress this week.',
                      startColor: _white.withOpacity(0.22),
                      endColor: _darkGreen.withOpacity(0.76),
                      onTap: () => Navigator.pushNamed(context, '/history'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      );
    }

    Widget _buildHeroSection({
      required BuildContext context,
      required String userName,
      required int hydrationCount,
      required int streakCount,
      required String moodEmoji,
      required bool hasCheckin,
      required double topOffset,
    }) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, topOffset + 10, 16, 22),
        decoration: BoxDecoration(
          color: _yellow.withOpacity(0.72),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.elliptical(240, 88),
            bottomRight: Radius.elliptical(240, 88),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: _black,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
                children: [
                  const TextSpan(text: 'Good Morning, '),
                  TextSpan(
                    text: '$userName!',
                    style: GoogleFonts.inter(
                      color: _pink,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeroMetric(
                  emoji: '💧',
                  value: '$hydrationCount',
                  label: 'Hydration',
                  emojiSize: 22,
                  valueSize: 24,
                ),
                _buildHeroMetric(
                  emoji: '🔥',
                  value: '$streakCount',
                  label: 'Current Streak',
                ),
                _buildHeroMetric(
                  emoji: moodEmoji,
                  value: '',
                  label: 'Current Mood',
                  isMood: true,
                  emojiSize: 26,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: _black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: 'Complete today\'s '),
                    TextSpan(
                      text: 'check-in',
                      style: GoogleFonts.inter(
                        color: _pink,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' to protect your streak.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkin'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _pink,
                      foregroundColor: _white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      minimumSize: const Size(100, 42),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(hasCheckin ? 'Update' : 'Check-In'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/journal'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: _white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      minimumSize: const Size(100, 42),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Journal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildHeroMetric({
      required String emoji,
      required String value,
      required String label,
      bool isMood = false,
      double emojiSize = 30,
      double valueSize = 36,
    }) {
      return Expanded(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Center(
                child: isMood
                    ? Text(emoji, style: TextStyle(fontSize: emojiSize))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(emoji, style: TextStyle(fontSize: emojiSize)),
                          const SizedBox(width: 6),
                          Text(
                            value,
                            style: TextStyle(
                              color: _black,
                              fontSize: valueSize,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSnapshotCard({
      required bool hasCheckin,
      required String moodEmoji,
      required double sleepHours,
      required bool exercised,
    }) {
      if (hasCheckin) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _pink.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _pink.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSnapshotMiniTile(
                      icon: moodEmoji,
                      label: 'Mood',
                      value: 'Logged',
                      bg: _blue.withOpacity(0.22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSnapshotMiniTile(
                      icon: '😴',
                      label: 'Sleep',
                      value: '${sleepHours.toStringAsFixed(1)}h',
                      bg: _yellow.withOpacity(0.36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSnapshotMiniTile(
                      icon: exercised ? '🏃' : '🪑',
                      label: 'Exercise',
                      value: exercised ? 'Yes' : 'No',
                      bg: _green.withOpacity(0.52),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _pink.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY',
              style: TextStyle(
                color: _pink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No check-in record yet.',
              style: TextStyle(
                color: _black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Start your day by logging mood, sleep, and habits.',
              style: TextStyle(
                color: _black,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSnapshotMiniTile({
      required String icon,
      required String label,
      required String value,
      required Color bg,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: _black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    String _formatName(String name) {
      if (name.isEmpty) {
        return 'Friend';
      }

      final cleaned = name.replaceAll('.', ' ').trim();
      if (cleaned.isEmpty) {
        return 'Friend';
      }

      final parts = cleaned
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.isEmpty) {
        return 'Friend';
      }

      final first = parts.first;
      return '${first[0].toUpperCase()}${first.substring(1).toLowerCase()}';
    }
  }
