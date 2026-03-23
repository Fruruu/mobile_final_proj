import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/checkin_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {

  Widget _moodButton(
    CheckinViewModel vm,
    int mood,
    String emoji,
  ) {
    final isSelected = vm.selectedMood == mood;
    return GestureDetector(
      onTap: () => vm.setMood(mood),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckinViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // MOOD SELECTOR
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _moodButton(vm, 1, '😰'),
                _moodButton(vm, 2, '😔'),
                _moodButton(vm, 3, '😐'),
                _moodButton(vm, 4, '🙂'),
                _moodButton(vm, 5, '😄'),
              ],
            ),
            const SizedBox(height: 32),

            // SLEEP HOURS
            const Text(
              'How many hours did you sleep?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${vm.sleepHours.toStringAsFixed(1)} hours',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            Slider(
              value: vm.sleepHours,
              min: 0,
              max: 12,
              divisions: 24,
              activeColor: Colors.deepPurple,
              onChanged: (value) => vm.setSleepHours(value),
            ),
            const SizedBox(height: 32),

            // EXERCISE TOGGLE
            const Text(
              'Did you exercise today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: vm.exercised,
                  activeThumbColor: Colors.deepPurple,
                  onChanged: (value) =>
                      vm.setExercised(value),
                ),
                Text(
                  vm.exercised ? 'Yes! 💪' : 'No',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // WATER GLASSES
            const Text(
              'How many glasses of water?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (vm.waterGlasses > 0) {
                      vm.setWaterGlasses(
                          vm.waterGlasses - 1);
                    }
                  },
                  icon: const Icon(
                      Icons.remove_circle_outline),
                  color: Colors.deepPurple,
                  iconSize: 32,
                ),
                Text(
                  '${vm.waterGlasses} 💧',
                  style: const TextStyle(fontSize: 24),
                ),
                IconButton(
                  onPressed: () {
                    vm.setWaterGlasses(
                        vm.waterGlasses + 1);
                  },
                  icon: const Icon(
                      Icons.add_circle_outline),
                  color: Colors.deepPurple,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ERROR MESSAGE
            if (vm.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  vm.errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ),

            // SUBMIT BUTTON
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      if (user != null) {
                        // Check if today's check-in already exists
                        final exists = await vm
                            .todayCheckinExists(user.id);

                        if (exists && context.mounted) {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Update Check-in?',
                              ),
                              content: const Text(
                                'You already checked in today. '
                                'Would you like to update it?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await vm.submitCheckin(
                                        user.id);
                                    if (vm.success &&
                                        context
                                            .mounted) {
                                      Navigator.pushNamed(
                                        context,
                                        '/insight',
                                        arguments: {
                                          'aiMood':
                                              vm.aiMood,
                                          'aiInsight': vm
                                              .aiInsight,
                                          'source':
                                              'checkin',
                                        },
                                      );
                                    }
                                  },
                                  style: ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                        Colors.deepPurple,
                                    foregroundColor:
                                        Colors.white,
                                  ),
                                  child:
                                      const Text('Update'),
                                ),
                              ],
                            ),
                          );
                        } else if (!exists &&
                            context.mounted) {
                          // No existing check-in, proceed normally
                          await vm.submitCheckin(user.id);
                          if (vm.success &&
                              context.mounted) {
                            Navigator.pushNamed(
                              context,
                              '/insight',
                              arguments: {
                                'aiMood': vm.aiMood,
                                'aiInsight':
                                    vm.aiInsight,
                                'source': 'checkin',
                              },
                            );
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text(
                      'Save Check-in',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}