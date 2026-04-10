import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/checkin_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/frosted_app_bar.dart';
import '../../theme/app_colors.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  static const Color _bg = AppColors.white;
  static const Color _primary = AppColors.primaryPink;
  static const Color _muted = AppColors.black;
  PageController? _moodPageController;

  PageController get _carouselController {
    return _moodPageController ??= PageController(
      viewportFraction: 0.43,
      initialPage: 2,
    );
  }

  static const List<_MoodOption> _moodOptions = [
    _MoodOption(
      mood: 5,
      label: 'Very Happy',
      asset: 'assets/logos/very-happy-face.svg',
      cardColor: Color(0xFFC3FFA7),
    ),
    _MoodOption(
      mood: 4,
      label: 'Happy',
      asset: 'assets/logos/happy-face.svg',
      cardColor: Color(0xFF4EC1F5),
    ),
    _MoodOption(
      mood: 3,
      label: 'Neutral',
      asset: 'assets/logos/neutral-face.svg',
      cardColor: Color(0xFFFF6169),
    ),
    _MoodOption(
      mood: 2,
      label: 'Sad',
      asset: 'assets/logos/sad-face.svg',
      cardColor: Color(0xFFFFDE71),
    ),
    _MoodOption(
      mood: 1,
      label: 'Very Sad',
      asset: 'assets/logos/very-sad-face.svg',
      cardColor: Color(0xFFFF9800),
    ),
  ];

  @override
  void dispose() {
    _moodPageController?.dispose();
    super.dispose();
  }

  Widget _buildMoodCarousel(CheckinViewModel vm) {
    final selectedIndex = _moodOptions.indexWhere(
      (option) => option.mood == vm.selectedMood,
    );

    if (selectedIndex >= 0) {
      final target = selectedIndex.toDouble();
      final current = _carouselController.hasClients
          ? (_carouselController.page ??
                _carouselController.initialPage.toDouble())
          : _carouselController.initialPage.toDouble();
      if ((current - target).abs() > 0.01 && _carouselController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _carouselController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }

    return SizedBox(
      height: 210, // increased to accommodate label
      child: PageView.builder(
        controller: _carouselController,
        clipBehavior: Clip.none,
        onPageChanged: (index) => vm.setMood(_moodOptions[index].mood),
        itemCount: _moodOptions.length,
        itemBuilder: (context, index) {
          final option = _moodOptions[index];
          final selected = option.mood == vm.selectedMood;

          final card = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: option.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(selected ? 0.14 : 0.08),
                  blurRadius: selected ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                option.asset,
                width: selected ? 98 : 72,
                height: selected ? 98 : 72,
                fit: BoxFit.contain,
              ),
            ),
          );

          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: selected ? 0 : 22,
            ),
            child: GestureDetector(
              onTap: () {
                vm.setMood(option.mood);
                _carouselController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: selected
                        ? card
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.0, 0.18, 0.82, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                              ).createShader(bounds),
                              child: card,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: GoogleFonts.inter(
                      fontSize: selected ? 13 : 11,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.black
                          : AppColors.black.withOpacity(0.4),
                    ),
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckinViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Daily Check-in'),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            left: -90,
            right: -90,
            child: Container(
              height: 580,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(420, 190),
                  bottomRight: Radius.elliptical(420, 190),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withOpacity(0.55),
                    blurRadius: 42,
                    spreadRadius: 8,
                  ),
                ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day!',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                // const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: 'How are you '),
                      TextSpan(
                        text: 'feeling',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryPink,
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' today?'),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                _buildMoodCarousel(vm),
                const SizedBox(height: 18),

                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sleep',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${vm.sleepHours.toStringAsFixed(1)} hours',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Slider(
                        value: vm.sleepHours,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        activeColor: _primary,
                        onChanged: (value) => vm.setSleepHours(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _glassCard(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Exercise',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        vm.exercised ? 'Yes' : 'No',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Switch(
                        value: vm.exercised,
                        activeColor: _primary,
                        onChanged: (value) => vm.setExercised(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _glassCard(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Water Intake',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      _roundIconButton(
                        Icons.remove,
                        onTap: () {
                          if (vm.waterGlasses > 0) {
                            vm.setWaterGlasses(vm.waterGlasses - 1);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${vm.waterGlasses} 💧',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _roundIconButton(
                        Icons.add,
                        onTap: () {
                          vm.setWaterGlasses(vm.waterGlasses + 1);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      vm.errorMessage,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            if (user != null) {
                              // Check if today's check-in already exists
                              final exists = await vm.todayCheckinExists(user.id);

                              if (exists && context.mounted) {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Update Check-in?'),
                                    content: const Text(
                                      'You already checked in today. '
                                      'Would you like to update it?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await _submitAndNavigateToInsight(
                                            vm,
                                            user.id,
                                            closeDialogFirst: true,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primary,
                                          foregroundColor: AppColors.white,
                                        ),
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (!exists && context.mounted) {
                                // No existing check-in, proceed normally
                                await _submitAndNavigateToInsight(vm, user.id);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      shadowColor: _primary.withOpacity(0.3),
                      backgroundColor: _primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: vm.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Complete Check-in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.done_all),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Map<String, dynamic> _buildCheckinData(CheckinViewModel vm) {
    return {
      'user_mood': vm.selectedMood,
      'sleep_hours': vm.sleepHours,
      'exercised': vm.exercised,
      'water_glasses': vm.waterGlasses,
    };
  }

  Future<void> _submitAndNavigateToInsight(
    CheckinViewModel vm,
    String userId, {
    bool closeDialogFirst = false,
  }) async {
    final checkinData = _buildCheckinData(vm);

    if (closeDialogFirst && context.mounted) {
      Navigator.pop(context);
    }

    await vm.submitCheckin(userId);

    if (vm.success && context.mounted) {
      Navigator.pushNamed(
        context,
        '/insight',
        arguments: {
          'aiMood': vm.aiMood,
          'aiInsight': vm.aiInsight,
          'source': 'checkin',
          'checkinData': checkinData,
        },
      );
    }
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _roundIconButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD8DADA)),
        ),
        child: Icon(icon, color: _primary, size: 18),
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption({
    required this.mood,
    required this.label,
    required this.asset,
    required this.cardColor,
  });

  final int mood;
  final String label;
  final String asset;
  final Color cardColor;
}