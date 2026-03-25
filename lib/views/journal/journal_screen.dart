import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/journal_view_model.dart';
import '../../widgets/app_bottom_nav.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalController = TextEditingController();

  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _text = Color(0xFF2D2F2F);
  static const Color _muted = Color(0xFF5A5C5C);

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
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Journal',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: _bg,
        foregroundColor: _primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FFD1DC),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22DDFCDE),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'What\'s on your mind today?',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a moment to breathe and reflect.',
                  style: TextStyle(fontSize: 16, color: _muted),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _journalController,
                    maxLines: 10,
                    onChanged: (value) {
                      vm.setJournalText(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Start typing here...',
                      hintStyle: TextStyle(
                        color: _muted.withOpacity(0.65),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    ),
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_journalController.text.length} characters',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                if (vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      vm.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ElevatedButton(
                  onPressed: vm.isLoading || _journalController.text.isEmpty
                      ? null
                      : () async {
                          if (user != null) {
                            final exists = await vm.todayJournalExists(user.id);

                            if (exists && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Update Journal Entry?'),
                                  content: const Text(
                                    'You already wrote a journal entry today. '
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
                                        await vm.submitJournal(user.id);
                                        if (vm.success && context.mounted) {
                                          _journalController.clear();
                                          Navigator.pushNamed(
                                            context,
                                            '/insight',
                                            arguments: {
                                              'aiMood': vm.aiMood,
                                              'aiInsight': vm.aiInsight,
                                              'source': 'journal',
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
                              await vm.submitJournal(user.id);
                              if (vm.success && context.mounted) {
                                _journalController.clear();
                                Navigator.pushNamed(
                                  context,
                                  '/insight',
                                  arguments: {
                                    'aiMood': vm.aiMood,
                                    'aiInsight': vm.aiInsight,
                                    'source': 'journal',
                                  },
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: _primary.withOpacity(0.28),
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
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
                              'Save Journal Entry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, '
        '${months[now.month - 1]} '
        '${now.day}, ${now.year}';
  }
}
