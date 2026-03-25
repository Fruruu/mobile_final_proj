import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view_models/history_view_model.dart';
import '../../models/daily_checkin.dart';
import '../../models/journal_entry.dart';
import '../../widgets/app_bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _initialized = false;

  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Load check-in and journal history
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final vm = Provider.of<HistoryViewModel>(context, listen: false);
        vm.loadHistory(user.id);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HistoryViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity History',
          style: TextStyle(fontWeight: FontWeight.w700, color: _primary),
        ),
        backgroundColor: _bg,
        foregroundColor: _primary,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : vm.errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  vm.errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : vm.checkins.isEmpty && vm.journals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No activity yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your mood and journaling!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vm.getCombinedTimeline().length,
              itemBuilder: (context, index) {
                final item = vm.getCombinedTimeline()[index];
                if (item is DailyCheckin) {
                  return _buildCheckinCard(context, item, vm, user?.id ?? '');
                } else {
                  return _buildJournalCard(
                    context,
                    item as JournalEntry,
                    vm,
                    user?.id ?? '',
                  );
                }
              },
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildCheckinCard(
    BuildContext context,
    dynamic checkin,
    HistoryViewModel vm,
    String userId,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to insight screen with this check-in's data
        Navigator.pushNamed(
          context,
          '/insight',
          arguments: {
            'aiMood': checkin.aiMood ?? 'No mood detected',
            'aiInsight': checkin.aiInsight ?? 'No insight available',
            'source': 'history',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and mood row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.formatDate(checkin.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mood: ${vm.getMoodText(checkin.userMood)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    vm.getMoodEmoji(checkin.userMood),
                    style: const TextStyle(fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details row (sleep, exercise, water)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    '😴 Sleep',
                    '${checkin.sleepHours?.toStringAsFixed(1) ?? 0} hrs',
                  ),
                  _buildDetailItem(
                    '💪 Exercise',
                    checkin.exercised ? 'Yes' : 'No',
                  ),
                  _buildDetailItem(
                    '💧 Water',
                    '${checkin.waterGlasses ?? 0} glasses',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Insight preview
              if (checkin.aiInsight != null && checkin.aiInsight.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Insight',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checkin.aiInsight.substring(
                          0,
                          checkin.aiInsight.length > 100
                              ? 100
                              : checkin.aiInsight.length,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context, checkin.id, vm, userId);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildJournalCard(
    BuildContext context,
    JournalEntry journal,
    HistoryViewModel vm,
    String userId,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to insight screen with this journal's data
        Navigator.pushNamed(
          context,
          '/insight',
          arguments: {
            'aiMood': journal.aiMood ?? 'No mood detected',
            'aiInsight': journal.aiInsight ?? 'No insight available',
            'source': 'history',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and journal icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.formatDate(journal.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Journal Entry',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text('📓', style: const TextStyle(fontSize: 40)),
                ],
              ),
              const SizedBox(height: 12),

              // Journal text preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entry',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      journal.journalText?.substring(
                            0,
                            journal.journalText!.length > 100
                                ? 100
                                : journal.journalText!.length,
                          ) ??
                          'No text',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // AI Insight preview
              if (journal.aiInsight != null && journal.aiInsight!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Insight',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        journal.aiInsight!.substring(
                          0,
                          journal.aiInsight!.length > 100
                              ? 100
                              : journal.aiInsight!.length,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteJournalConfirmation(
                      context,
                      journal.id!,
                      vm,
                      userId,
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String checkinId,
    HistoryViewModel vm,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Check-in?'),
        content: const Text(
          'Are you sure you want to delete this check-in? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteCheckin(checkinId, userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteJournalConfirmation(
    BuildContext context,
    String journalId,
    HistoryViewModel vm,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal Entry?'),
        content: const Text(
          'Are you sure you want to delete this journal entry? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteJournal(journalId, userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
