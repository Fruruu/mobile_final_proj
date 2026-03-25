import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/report_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/app_bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _primarySoft = Color(0xFFFFD1DC);
  static const Color _text = Color(0xFF2D2F2F);
  static const Color _muted = Color(0xFF5A5C5C);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReportViewModel>().loadReports(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, color: _primary),
        ),
        backgroundColor: _bg,
        foregroundColor: _primary,
        elevation: 0,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                viewModel.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly/Monthly Toggle
                _buildViewToggle(context, viewModel),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(viewModel),
                const SizedBox(height: 24),

                // Habit-Mood Correlation
                _buildCorrelationSection(viewModel),
                const SizedBox(height: 24),

                // AI Insight
                _buildInsightCard(viewModel),
                const SizedBox(height: 24),

                // Mood Distribution
                _buildMoodDistribution(viewModel),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildViewToggle(BuildContext context, ReportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.switchView('weekly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: viewModel.selectedView == 'weekly'
                      ? _primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📅 Weekly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: viewModel.selectedView == 'weekly'
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.switchView('monthly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: viewModel.selectedView == 'monthly'
                      ? _primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📊 Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: viewModel.selectedView == 'monthly'
                        ? Colors.white
                        : Colors.grey.shade700,
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
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'KEY METRICS',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              _buildStatCard(
                '😊 Mood',
                viewModel.averageMood.toStringAsFixed(1),
                '/5',
                const Color(0xFFE7F6FD),
              ),
              _buildStatCard(
                '😴 Sleep',
                viewModel.averageSleep.toStringAsFixed(1),
                'hrs',
                const Color(0xFFEFF0FF),
              ),
              _buildStatCard(
                '🏃 Exercise',
                viewModel.exerciseCount.toString(),
                'days',
                const Color(0xFFFEEFCF),
              ),
              _buildStatCard(
                '💧 Water',
                viewModel.averageWater.toStringAsFixed(1),
                'glasses',
                const Color(0xFFDDF1FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              label.split(' ').first,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.split(' ').skip(1).join(' '),
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationSection(ReportViewModel viewModel) {
    final exerciseDiff =
        (viewModel.moodWithExercise - viewModel.moodWithoutExercise)
            .toStringAsFixed(1);
    final sleepDiff =
        (viewModel.moodWithGoodSleep - viewModel.moodWithPoorSleep)
            .toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit-Mood Correlation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildCorrelationCard(
          '🏃 Exercise Impact',
          'With exercise: ${viewModel.moodWithExercise.toStringAsFixed(1)}/5',
          'Without: ${viewModel.moodWithoutExercise.toStringAsFixed(1)}/5',
          'Mood difference: ${exerciseDiff}',
          viewModel.moodWithExercise > viewModel.moodWithoutExercise,
        ),
        const SizedBox(height: 12),
        _buildCorrelationCard(
          '😴 Sleep Impact',
          'Good sleep (7+h): ${viewModel.moodWithGoodSleep.toStringAsFixed(1)}/5',
          'Poor sleep: ${viewModel.moodWithPoorSleep.toStringAsFixed(1)}/5',
          'Mood difference: ${sleepDiff}',
          viewModel.moodWithGoodSleep > viewModel.moodWithPoorSleep,
        ),
      ],
    );
  }

  Widget _buildCorrelationCard(
    String title,
    String line1,
    String line2,
    String line3,
    bool positive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: positive
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            line1,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            line2,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: positive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              line3,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: positive
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ReportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withOpacity(0.82), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ AI Insight',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.insightText,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: moodFreq.entries.toList().reversed.map((entry) {
              final mood = entry.key;
              final count = entry.value;
              final percentage = (count / viewModel.checkins.length * 100);
              final moodEmoji = viewModel.getMoodEmoji(mood);
              final moodLabel = _getMoodLabel(mood);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$moodEmoji $moodLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getMoodColor(mood),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

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

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
