import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../view_models/report_view_model.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/frosted_app_bar.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color _bg = Color(0xFFF4EFF1);
  static const Color _primary = AppColors.primaryPink;
  static const Color _primarySoft = Color(0x26FF6169);
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReportViewModel>().loadReports(userId);
      });
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Reports & Analytics'),
      body: Consumer<ReportViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  viewModel.errorMessage,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Stack(
            children: [
              Positioned(
                top: 80,
                left: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x22FFDE71),
                  ),
                ),
              ),
              Positioned(
                top: 320,
                right: -90,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1A4EC1F5),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  14,
                  FrostedAppBar.barHeight + 60,
                  14,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSummary(viewModel),
                    const SizedBox(height: 10),
                    _buildViewToggle(viewModel),
                    const SizedBox(height: 10),
                    _buildStatsCards(viewModel),
                    const SizedBox(height: 10),
                    _buildCorrelationSection(viewModel),
                    const SizedBox(height: 10),
                    _buildMoodDistribution(viewModel),
                    const SizedBox(height: 10),
                    _buildInsightCard(viewModel),
                    const SizedBox(height: 10),
                    _buildNextFocusCard(viewModel),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeroSummary(ReportViewModel viewModel) {
    final expected = viewModel.selectedView == 'weekly' ? 7 : 30;
    final tracked = viewModel.checkins.length;
    final coverage = expected == 0
        ? 0.0
        : (tracked / expected).clamp(0.0, 1.0).toDouble();
    final moodEntry = _getDominantMoodEntry(viewModel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.56),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Mood Story',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.selectedView == 'weekly'
                ? 'Weekly snapshot of your habits and feelings.'
                : 'Monthly snapshot of your habits and feelings.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMiniCard(
                  title: 'Tracked Days',
                  value: '$tracked/$expected',
                  color: AppColors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryMiniCard(
                  title: 'Dominant Mood',
                  value: moodEntry == null
                      ? 'N/A'
                      : '${viewModel.getMoodEmoji(moodEntry.key)} ${_getMoodLabel(moodEntry.key)}',
                  color: AppColors.white.withOpacity(0.92),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: coverage,
              minHeight: 10,
              backgroundColor: AppColors.white.withOpacity(0.75),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Consistency ${(coverage * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMiniCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(ReportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => viewModel.switchView('weekly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: viewModel.selectedView == 'weekly'
                      ? _primary
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Weekly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: viewModel.selectedView == 'weekly'
                        ? AppColors.white
                        : _muted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => viewModel.switchView('monthly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: viewModel.selectedView == 'monthly'
                      ? _primary
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: viewModel.selectedView == 'monthly'
                        ? AppColors.white
                        : _muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ReportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.09),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'VIBE SNAPSHOT',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 112,
            ),
            children: [
              _buildStatCard(
                Icons.mood_rounded,
                'Mood Avg',
                viewModel.averageMood.toStringAsFixed(1),
                '/5',
                AppColors.blue.withOpacity(0.23),
              ),
              _buildStatCard(
                Icons.bedtime_rounded,
                'Sleep Avg',
                viewModel.averageSleep.toStringAsFixed(1),
                'hrs',
                AppColors.yellow.withOpacity(0.35),
              ),
              _buildStatCard(
                Icons.directions_run_rounded,
                'Exercise',
                viewModel.exerciseCount.toString(),
                'days',
                AppColors.green.withOpacity(0.52),
              ),
              _buildStatCard(
                Icons.local_drink_rounded,
                'Water Avg',
                viewModel.averageWater.toStringAsFixed(1),
                'glasses',
                AppColors.blue.withOpacity(0.15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String unit,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 15,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationSection(ReportViewModel viewModel) {
    final exerciseDiff =
        viewModel.moodWithExercise - viewModel.moodWithoutExercise;
    final sleepDiff =
        viewModel.moodWithGoodSleep - viewModel.moodWithPoorSleep;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pattern Radar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'How habits shift your mood score.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
          const SizedBox(height: 12),
          _buildImpactRow(
            title: 'Exercise Impact',
            goodValue: viewModel.moodWithExercise,
            baselineValue: viewModel.moodWithoutExercise,
            diff: exerciseDiff,
            color: AppColors.darkGreen,
            icon: Icons.directions_run_rounded,
          ),
          const SizedBox(height: 10),
          _buildImpactRow(
            title: 'Sleep Impact',
            goodValue: viewModel.moodWithGoodSleep,
            baselineValue: viewModel.moodWithPoorSleep,
            diff: sleepDiff,
            color: AppColors.blue,
            icon: Icons.bedtime_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({
    required String title,
    required double goodValue,
    required double baselineValue,
    required double diff,
    required Color color,
    required IconData icon,
  }) {
    final positive = diff >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _text, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const Spacer(),
              Text(
                '${positive ? '+' : ''}${diff.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: positive ? AppColors.darkGreen : AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Healthy habit: ${goodValue.toStringAsFixed(1)}/5',
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Baseline: ${baselineValue.toStringAsFixed(1)}/5',
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(ReportViewModel viewModel) {
    final moodFreq = viewModel.moodFrequency;
    if (moodFreq.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedMoods = moodFreq.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Mix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your emotional distribution in this period.',
            style: TextStyle(
              fontSize: 13,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedMoods.map((entry) {
            final mood = entry.key;
            final count = entry.value;
            final percentage =
                (count / viewModel.checkins.length).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMoodBar(
                emoji: viewModel.getMoodEmoji(mood),
                label: _getMoodLabel(mood),
                percentage: percentage,
                count: count,
                color: _getMoodColor(mood),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodBar({
    required String emoji,
    required String label,
    required double percentage,
    required int count,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$emoji $label',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const Spacer(),
            Text(
              '$count days',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 9,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ReportViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primary.withOpacity(0.92),
            _primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insight',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.insightText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextFocusCard(ReportViewModel viewModel) {
    final nextFocus = _buildFocusMessage(viewModel);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: _text,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nextFocus,
              style: const TextStyle(
                fontSize: 13,
                color: _text,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildFocusMessage(ReportViewModel viewModel) {
    if (viewModel.checkins.isEmpty) {
      return 'Start with your first check-in to unlock personalized patterns.';
    }

    if (viewModel.averageSleep < 7) {
      return 'Your mood trends improve with rest. Try aiming for at least 7 hours tonight.';
    }

    if (viewModel.averageWater < 6) {
      return 'Hydration is a growth lever. Push your daily water target slightly higher.';
    }

    final minExercise = viewModel.selectedView == 'weekly' ? 3 : 12;
    if (viewModel.exerciseCount < minExercise) {
      return 'Movement can lift your mood. Add short exercise sessions this period.';
    }

    return 'Great balance this period. Keep your routine steady and protect your streak.';
  }

  MapEntry<int, int>? _getDominantMoodEntry(ReportViewModel viewModel) {
    if (viewModel.moodFrequency.isEmpty) {
      return null;
    }

    final entries = viewModel.moodFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first;
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
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

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return AppColors.red;
      case 2:
        return AppColors.orange;
      case 3:
        return AppColors.yellow;
      case 4:
        return AppColors.blue;
      case 5:
        return AppColors.darkGreen;
      default:
        return _muted;
    }
  }
}
