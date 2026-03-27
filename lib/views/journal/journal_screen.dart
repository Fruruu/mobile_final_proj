import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/journal_view_model.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/frosted_app_bar.dart';
import '../../theme/app_colors.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalController = TextEditingController();

  static const Color _bg = Color(0xFFF4EFF1);
  static const Color _primary = AppColors.primaryPink;
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);

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
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Journal'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              10,
              MediaQuery.of(context).padding.top + FrostedAppBar.barHeight + 10,
              10,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                    children: [
                      TextSpan(text: 'What\'s on your '),
                      TextSpan(
                        text: 'mind',
                        style: TextStyle(
                          color: _primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(text: ' today?'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a moment to breathe and reflect.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  constraints: const BoxConstraints(minHeight: 330),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDDE0).withOpacity(0.58),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _journalController,
                    minLines: 15,
                    maxLines: null,
                    onChanged: (value) {
                      vm.setJournalText(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Start typing here...',
                      hintStyle: TextStyle(
                        color: _primary.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    ),
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_journalController.text.length} characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: _primary.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 14),
                if (vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      vm.errorMessage,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 13,
                      ),
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
                                        foregroundColor: AppColors.white,
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
                    elevation: 0,
                    backgroundColor: _primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: vm.isLoading
                      ? const Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        )
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
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 20),
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
}
