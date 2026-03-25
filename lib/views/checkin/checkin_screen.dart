import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/checkin_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/app_bottom_nav.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _muted = Color(0xFF5A5C5C);

  Widget _moodButton(
    CheckinViewModel vm,
    int mood,
    String emoji,
    String label,
    Color bg,
  ) {
    final isSelected = vm.selectedMood == mood;
    return GestureDetector(
      onTap: () => vm.setMood(mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD1DC) : bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _primary : Colors.white,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckinViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Daily Check-in',
          style: TextStyle(fontWeight: FontWeight.w700, color: _primary),
        ),
        backgroundColor: _bg,
        foregroundColor: _primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: -70,
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
            bottom: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22DDFCDE),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good day.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2F2F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'How are you feeling in this moment?',
                  style: TextStyle(fontSize: 16, color: _muted),
                ),
                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.72,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _moodButton(
                      vm,
                      5,
                      '😄',
                      'Radiant',
                      const Color(0xFFDDFCDE),
                    ),
                    _moodButton(vm, 4, '🙂', 'Calm', const Color(0xFFB2E4FB)),
                    _moodButton(vm, 3, '😐', 'Steady', const Color(0xFFE7E8E8)),
                    _moodButton(vm, 2, '😔', 'Heavy', const Color(0xFFF0F1F1)),
                    _moodButton(
                      vm,
                      1,
                      '😰',
                      'Fragile',
                      const Color(0xFFFCE2E8),
                    ),
                  ],
                ),
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
                          color: Color(0xFF2D2F2F),
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
                            color: Color(0xFF2D2F2F),
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
                            color: Color(0xFF2D2F2F),
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
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),

                ElevatedButton(
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
                                        Navigator.pop(context);
                                        await vm.submitCheckin(user.id);
                                        if (vm.success && context.mounted) {
                                          Navigator.pushNamed(
                                            context,
                                            '/insight',
                                            arguments: {
                                              'aiMood': vm.aiMood,
                                              'aiInsight': vm.aiInsight,
                                              'source': 'checkin',
                                            },
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Update'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (!exists && context.mounted) {
                              // No existing check-in, proceed normally
                              await vm.submitCheckin(user.id);
                              if (vm.success && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/insight',
                                  arguments: {
                                    'aiMood': vm.aiMood,
                                    'aiInsight': vm.aiInsight,
                                    'source': 'checkin',
                                  },
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    shadowColor: _primary.withOpacity(0.3),
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD8DADA)),
        ),
        child: Icon(icon, color: _primary, size: 18),
      ),
    );
  }
}
