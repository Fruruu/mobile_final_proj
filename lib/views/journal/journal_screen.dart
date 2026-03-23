import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/journal_view_model.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalController = TextEditingController();

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Journal Entry'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // DATE
            Text(
              _getFormattedDate(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // TITLE
            const Text(
              'How was your day?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Write about anything on your mind.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // JOURNAL TEXT FIELD
            TextField(
              controller: _journalController,
              maxLines: 10,
              onChanged: (value) {
                vm.setJournalText(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Start writing here...',
                hintStyle:
                    const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            // CHARACTER COUNT
            Text(
              '${_journalController.text.length} characters',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),

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
              onPressed: vm.isLoading ||
                      _journalController.text.isEmpty
                  ? null
                  : () async {
                      if (user != null) {
                        // Check if today's journal entry already exists
                        final exists = await vm
                            .todayJournalExists(user.id);

                        if (exists && context.mounted) {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Update Journal Entry?',
                              ),
                              content: const Text(
                                'You already wrote a journal entry today. '
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
                                    await vm.submitJournal(
                                        user.id);
                                    if (vm.success &&
                                        context
                                            .mounted) {
                                      _journalController
                                          .clear();
                                      Navigator.pushNamed(
                                        context,
                                        '/insight',
                                        arguments: {
                                          'aiMood':
                                              vm.aiMood,
                                          'aiInsight': vm
                                              .aiInsight,
                                          'source':
                                              'journal',
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
                          // No existing entry, proceed normally
                          await vm.submitJournal(user.id);
                          if (vm.success &&
                              context.mounted) {
                            _journalController.clear();
                            Navigator.pushNamed(
                              context,
                              '/insight',
                              arguments: {
                                'aiMood': vm.aiMood,
                                'aiInsight':
                                    vm.aiInsight,
                                'source': 'journal',
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
                      'Save Journal Entry',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March',
      'April', 'May', 'June', 'July',
      'August', 'September', 'October',
      'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[now.weekday - 1]}, '
        '${months[now.month - 1]} '
        '${now.day}, ${now.year}';
  }
}