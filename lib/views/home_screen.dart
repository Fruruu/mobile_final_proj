import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view_models/home_view_model.dart';
import '../view_models/profile_view_model.dart';
import '../view_models/report_view_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/check_list_item_card.dart';
import '../widgets/frosted_app_bar.dart';
import '../theme/app_colors.dart';

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
  static const Color _muted = Color(0xFF8F8B8C);
  static const Color _primarySoft = Color(0x26FF6169);

  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  /// 'weekly' or 'monthly'
  String _calendarView = 'weekly';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final homeVm = Provider.of<HomeViewModel>(context, listen: false);
        final profileVm =
            Provider.of<ProfileViewModel>(context, listen: false);
        final reportVm =
            Provider.of<ReportViewModel>(context, listen: false);
        homeVm.loadDashboard(user.id);
        profileVm.loadProfile(user.id);
        reportVm.loadReports(user.id);
      }
      _initialized = true;
    }
  }

  // ─── Normalize a DateTime to midnight (date-only key) ────────────────────

  /// Strips time components so DateTime map keys compare correctly.
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ─── Calendar helpers ────────────────────────────────────────────────────

  DateTime _weekStart(DateTime ref) {
    // weekday: Mon=1 … Sat=6, Sun=7  →  Sun=7%7=0 offset, Mon=1%7=1, etc.
    return _dateOnly(ref).subtract(Duration(days: ref.weekday % 7));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _calendarPrev() {
    setState(() {
      if (_calendarView == 'weekly') {
        _focusedDate = _focusedDate.subtract(const Duration(days: 7));
      } else {
        final m = _focusedDate.month == 1 ? 12 : _focusedDate.month - 1;
        final y = _focusedDate.month == 1
            ? _focusedDate.year - 1
            : _focusedDate.year;
        _focusedDate = DateTime(y, m, 1);
      }
    });
  }

  void _calendarNext() {
    final now = DateTime.now();
    setState(() {
      if (_calendarView == 'weekly') {
        final todaySunday = _weekStart(now);
        final focusedSunday = _weekStart(_focusedDate);
        if (focusedSunday.isBefore(todaySunday)) {
          _focusedDate = _focusedDate.add(const Duration(days: 7));
        }
      } else {
        final m = _focusedDate.month == 12 ? 1 : _focusedDate.month + 1;
        final y = _focusedDate.month == 12
            ? _focusedDate.year + 1
            : _focusedDate.year;
        final candidate = DateTime(y, m, 1);
        if (!candidate.isAfter(DateTime(now.year, now.month, 1))) {
          _focusedDate = candidate;
        }
      }
    });
  }

  bool _canGoNext() {
    final now = DateTime.now();
    if (_calendarView == 'weekly') {
      final todaySunday = _weekStart(now);
      return _weekStart(_focusedDate).isBefore(todaySunday);
    } else {
      return _focusedDate.year < now.year ||
          (_focusedDate.year == now.year &&
              _focusedDate.month < now.month);
    }
  }

  String _periodLabel() {
    if (_calendarView == 'weekly') {
      final start = _weekStart(_focusedDate);
      final end = DateTime(start.year, start.month, start.day + 6);
      return '${_shortDate(start)} – ${_shortDate(end)}';
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[_focusedDate.month - 1]} ${_focusedDate.year}';
    }
  }

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  String _moodEmoji(int mood) {
    switch (mood) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😄';
      default: return '❓';
    }
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1: return AppColors.red;
      case 2: return AppColors.orange;
      case 3: return AppColors.yellow;
      case 4: return AppColors.blue;
      case 5: return AppColors.darkGreen;
      default: return _muted;
    }
  }

  // ─── Build the moodMap from checkins with proper key normalization ────────

  Map<DateTime, int> _buildMoodMap(ReportViewModel reportVm) {
    final moodMap = <DateTime, int>{};
    for (final c in reportVm.checkins) {
      if (c.userMood == null) continue;
      // Always normalize to midnight so key equality works correctly
      final key = _dateOnly(c.date);
      moodMap[key] = c.userMood!;
    }
    return moodMap;
  }

  // ─── Shared calendar cell ─────────────────────────────────────────────────

  Widget _buildCalendarCell(
    DateTime day,
    int? mood,
    bool isToday,
    bool isFuture, {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 3),
    required VoidCallback? onTap,
  }) {
    final hasMood = mood != null && !isFuture;
    final isSelected =
        _selectedDate != null && _isSameDay(day, _selectedDate!);

    final cellColor =
        hasMood ? _getMoodColor(mood).withOpacity(0.82) : Colors.transparent;

    // Selected ring overrides today ring
    final borderColor = isSelected
        ? _black
        : isToday
            ? _pink
            : (hasMood ? Colors.transparent : _muted.withOpacity(0.25));

    return Expanded(
      child: GestureDetector(
        onTap: isFuture ? null : onTap,
        child: Padding(
          padding: padding,
          child: Opacity(
            opacity: isFuture ? 0.28 : 1.0,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || isToday) ? 2.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: hasMood
                    ? Text(_moodEmoji(mood),
                        style: const TextStyle(fontSize: 15))
                    : Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday
                              ? _pink
                              : _muted.withOpacity(0.55),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Selected day detail tooltip ──────────────────────────────────────────

  Widget _buildSelectedDayDetail(
      DateTime day, Map<DateTime, int> moodMap, ReportViewModel reportVm) {
    final key = _dateOnly(day);
    final mood = moodMap[key];

    // Find the full checkin record for this day (for extra details)
    final checkin = reportVm.checkins.where((c) {
      final d = _dateOnly(c.date);
      return d == key;
    }).firstOrNull;

    if (mood == null && checkin == null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _muted.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_shortDate(day)} — No check-in recorded',
                style: const TextStyle(
                  fontSize: 12,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mood != null
            ? _getMoodColor(mood).withOpacity(0.12)
            : _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mood != null
              ? _getMoodColor(mood).withOpacity(0.35)
              : _muted.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            mood != null ? _moodEmoji(mood) : '📅',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _shortDate(day),
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (mood != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _moodLabel(mood),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _getMoodColor(mood),
                    ),
                  ),
                ],
                if (checkin != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (checkin.sleepHours != null &&
                          checkin.sleepHours! > 0)
                        '😴 ${checkin.sleepHours!.toStringAsFixed(1)}h sleep',
                      if (checkin.exercised == true) '🏃 Exercised',
                      if (checkin.waterGlasses != null &&
                          checkin.waterGlasses! > 0)
                        '💧 ${checkin.waterGlasses} glasses',
                    ].join('  ·  '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _moodLabel(int mood) {
    switch (mood) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Neutral';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Unknown';
    }
  }

  // ─── Week row ─────────────────────────────────────────────────────────────

  Widget _buildWeekRow(Map<DateTime, int> moodMap) {
    final now = DateTime.now();
    final weekStart = _weekStart(_focusedDate);
    final days = List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
    return Row(
      children: days.map((day) {
        final key = _dateOnly(day);
        return _buildCalendarCell(
          day,
          moodMap[key],
          _isSameDay(day, now),
          day.isAfter(now),
          onTap: () => setState(() {
            _selectedDate = _isSameDay(day, _selectedDate ?? DateTime(0))
                ? null
                : day;
          }),
        );
      }).toList(),
    );
  }

  // ─── Month grid ───────────────────────────────────────────────────────────

  Widget _buildMonthGrid(Map<DateTime, int> moodMap) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final startOffset = firstOfMonth.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final day = DateTime(
                  _focusedDate.year, _focusedDate.month, dayNumber);
              final key = _dateOnly(day);
              return _buildCalendarCell(
                day,
                moodMap[key],
                _isSameDay(day, now),
                day.isAfter(now),
                padding: const EdgeInsets.all(2.5),
                onTap: () => setState(() {
                  _selectedDate = _isSameDay(day, _selectedDate ?? DateTime(0))
                      ? null
                      : day;
                }),
              );
            }),
          ),
        );
      }),
    );
  }

  // ─── Calendar card ────────────────────────────────────────────────────────

  Widget _buildHomeMoodCalendar(ReportViewModel reportVm) {
    final moodMap = _buildMoodMap(reportVm);

    final canNext = _canGoNext();
    final isWeekly = _calendarView == 'weekly';

    // Auto-clear selected date when navigating away from its visible range
    final selectedVisible = _selectedDate == null
        ? false
        : isWeekly
            ? _isDateInCurrentWeek(_selectedDate!)
            : _isDateInCurrentMonth(_selectedDate!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'MOOD CALENDAR',
                  style: TextStyle(
                    color: _pink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              _NavArrow(
                icon: Icons.chevron_left_rounded,
                onTap: _calendarPrev,
              ),
              const SizedBox(width: 6),
              Text(
                _periodLabel(),
                style: const TextStyle(
                  fontSize: 12,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              _NavArrow(
                icon: Icons.chevron_right_rounded,
                onTap: canNext ? _calendarNext : null,
                disabled: !canNext,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Weekly / Monthly toggle ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildToggleTab('weekly', 'Weekly')),
                const SizedBox(width: 6),
                Expanded(child: _buildToggleTab('monthly', 'Monthly')),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Day-of-week headers ────────────────────────────────────────
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (l) => Expanded(
                    child: Center(
                      child: Text(
                        l,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // ── Grid ──────────────────────────────────────────────────────
          isWeekly
              ? _buildWeekRow(moodMap)
              : _buildMonthGrid(moodMap),

          // ── Selected day detail ───────────────────────────────────────
          if (_selectedDate != null && selectedVisible)
            _buildSelectedDayDetail(_selectedDate!, moodMap, reportVm),

          const SizedBox(height: 16),

          // ── Legend ────────────────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              (5, 'Great'),
              (4, 'Good'),
              (3, 'Neutral'),
              (2, 'Low'),
              (1, 'Very Low'),
            ].map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _getMoodColor(e.$1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.$2,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isDateInCurrentWeek(DateTime date) {
    final start = _weekStart(_focusedDate);
    final end = DateTime(start.year, start.month, start.day + 6);
    final d = _dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool _isDateInCurrentMonth(DateTime date) {
    return date.year == _focusedDate.year &&
        date.month == _focusedDate.month;
  }

  Widget _buildToggleTab(String view, String label) {
    final active = _calendarView == view;
    return GestureDetector(
      onTap: () => setState(() {
        _calendarView = view;
        _focusedDate = DateTime.now();
        _selectedDate = null; // clear selection on view change
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? _pink : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? _white : _muted,
          ),
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);
    final profileVm = Provider.of<ProfileViewModel>(context);
    final reportVm = Provider.of<ReportViewModel>(context);

    final today = vm.todayCheckin;
    final hasCheckin = today != null;
    final userName = _formatName(profileVm.getDisplayName());
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
              topOffset: MediaQuery.of(context).padding.top +
                  FrostedAppBar.barHeight,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile completion banner
                  if (profileVm.profile == null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _orange.withOpacity(0.15),
                            _yellow.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: _orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('👤',
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Complete Your Profile',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Add your name & birthday for more personalized AI insights.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _black,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/profile-edit'),
                                  child: const Text(
                                    'Edit Profile →',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _pink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Mood Calendar ────────────────────────────────────
                  _buildHomeMoodCalendar(reportVm),
                  const SizedBox(height: 20),

                  // ── Today's Snapshot ─────────────────────────────────
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
                    subtitle:
                        '$hydrationCount/8 Glasses of water drank today.',
                    startColor: _white.withOpacity(0.22),
                    endColor: _blue,
                    isCompleted: hydrationCompleted,
                    onTap: () =>
                        Navigator.pushNamed(context, '/checkin'),
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
                    onTap: () =>
                        Navigator.pushNamed(context, '/checkin'),
                  ),
                  const SizedBox(height: 12),
                  CheckListItemCard(
                    leading: '📝',
                    title: 'Journal',
                    subtitle:
                        'Take a minute to write what you feel today.',
                    startColor: _white.withOpacity(0.22),
                    endColor: _orange.withOpacity(0.9),
                    onTap: () =>
                        Navigator.pushNamed(context, '/journal'),
                  ),
                  const SizedBox(height: 12),
                  CheckListItemCard(
                    leading: '📈',
                    title: 'Review History',
                    subtitle:
                        'See your mood trend and progress this week.',
                    startColor: _white.withOpacity(0.22),
                    endColor: _darkGreen.withOpacity(0.76),
                    onTap: () =>
                        Navigator.pushNamed(context, '/history'),
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

  // ─── Unchanged widgets below ─────────────────────────────────────────────

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
                style: const TextStyle(
                  color: _black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Complete today\'s '),
                  TextSpan(
                    text: 'check-in',
                    style: GoogleFonts.inter(
                      color: _pink,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' to protect your streak.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/checkin'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _pink,
                    foregroundColor: _white,
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.w600),
                    minimumSize: const Size(100, 42),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(hasCheckin ? 'Update' : 'Check-In'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/journal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: _white,
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.w600),
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
                        Text(emoji,
                            style: TextStyle(fontSize: emojiSize)),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
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
    if (name.isEmpty) return 'Friend';
    final cleaned = name.replaceAll('.', ' ').trim();
    if (cleaned.isEmpty) return 'Friend';
    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Friend';
    final first = parts.first;
    return '${first[0].toUpperCase()}${first.substring(1).toLowerCase()}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable nav arrow
// ─────────────────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF4EFF1)
              : const Color(0x26FF6169),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: disabled
              ? const Color(0xFF8F8B8C)
              : const Color(0xFFFF6169),
        ),
      ),
    );
  }
}