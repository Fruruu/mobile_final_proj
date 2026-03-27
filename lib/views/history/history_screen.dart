import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/daily_checkin.dart';
import '../../models/journal_entry.dart';
import '../../theme/app_colors.dart';
import '../../view_models/history_view_model.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/entry_checkin_card.dart';
import '../../widgets/frosted_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _initialized = false;
  String _filter = 'all';

  static const Color _bg = Color(0xFFF4EFF1);
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);
  static const Color _primary = AppColors.primaryPink;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final vm = Provider.of<HistoryViewModel>(context, listen: false);
      vm.loadHistory(user.id);
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HistoryViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Entries'),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          MediaQuery.of(context).padding.top + FrostedAppBar.barHeight + 10,
          14,
          18,
        ),
        child: _buildBody(vm, userId),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildBody(HistoryViewModel vm, String userId) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPink),
      );
    }

    if (vm.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.errorMessage,
            style: const TextStyle(color: AppColors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final timeline = _filteredTimeline(vm);
    if (timeline.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entries',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose an item to view full insight details.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _muted,
          ),
        ),
        const SizedBox(height: 10),
        _buildFilterRow(),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: timeline.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = timeline[index];
              if (item is DailyCheckin) {
                return _buildCheckinEntry(item, vm, userId);
              }
              return _buildJournalEntry(item as JournalEntry, vm, userId);
            },
          ),
        ),
      ],
    );
  }

  List<dynamic> _filteredTimeline(HistoryViewModel vm) {
    final all = vm.getCombinedTimeline();
    if (_filter == 'checkins') {
      return all.whereType<DailyCheckin>().toList();
    }
    if (_filter == 'journals') {
      return all.whereType<JournalEntry>().toList();
    }
    return all;
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildFilterChip(id: 'all', label: 'All'),
        const SizedBox(width: 8),
        _buildFilterChip(id: 'checkins', label: 'Check-ins'),
        const SizedBox(width: 8),
        _buildFilterChip(id: 'journals', label: 'Journals'),
      ],
    );
  }

  Widget _buildFilterChip({required String id, required String label}) {
    final selected = _filter == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filter = id),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _primary : AppColors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : _muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinEntry(
    DailyCheckin checkin,
    HistoryViewModel vm,
    String userId,
  ) {
    final moodText = (checkin.aiMood != null && checkin.aiMood!.trim().isNotEmpty)
        ? checkin.aiMood!.trim()
        : vm.getMoodText(checkin.userMood);
    final moodAssetPath = _getMoodAssetPath(
      moodText: moodText,
      fallbackMood: checkin.userMood,
    );

    return EntryCheckinCard(
      dateLabel: vm.formatDate(checkin.date),
      moodLabel: moodText,
      moodAssetPath: moodAssetPath,
      onTap: () => _openInsight(
        aiMood: checkin.aiMood,
        aiInsight: checkin.aiInsight,
        source: 'history',
      ),
      onMenuSelected: (value) {
        if (value == 'insight') {
          _openInsight(
            aiMood: checkin.aiMood,
            aiInsight: checkin.aiInsight,
            source: 'history',
          );
          return;
        }

        if (checkin.id != null && checkin.id!.isNotEmpty) {
          _showDeleteCheckinConfirmation(checkin.id!, userId);
        }
      },
    );
  }

  String _getMoodAssetPath({required String moodText, required int? fallbackMood}) {
    final normalized = moodText.toLowerCase();

    if (normalized.contains('great') ||
        normalized.contains('radiant') ||
        normalized.contains('very happy')) {
      return 'assets/logos/very-happy-face.svg';
    }
    if (normalized.contains('good') ||
        normalized.contains('calm') ||
        normalized.contains('happy')) {
      return 'assets/logos/happy-face.svg';
    }
    if (normalized.contains('neutral') || normalized.contains('steady')) {
      return 'assets/logos/neutral-face.svg';
    }
    if (normalized.contains('sad') ||
        normalized.contains('bad') ||
        normalized.contains('heavy') ||
        normalized.contains('low')) {
      return 'assets/logos/sad-face.svg';
    }
    if (normalized.contains('anxious') ||
        normalized.contains('fragile') ||
        normalized.contains('very bad') ||
        normalized.contains('very low')) {
      return 'assets/logos/very-sad-face.svg';
    }

    switch (fallbackMood) {
      case 5:
        return 'assets/logos/very-happy-face.svg';
      case 4:
        return 'assets/logos/happy-face.svg';
      case 3:
        return 'assets/logos/neutral-face.svg';
      case 2:
        return 'assets/logos/sad-face.svg';
      case 1:
        return 'assets/logos/very-sad-face.svg';
      default:
        return 'assets/logos/neutral-face.svg';
    }
  }

  Widget _buildJournalEntry(
    JournalEntry journal,
    HistoryViewModel vm,
    String userId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.yellow.withOpacity(0.42),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.menu_book_rounded,
            size: 20,
            color: _text,
          ),
        ),
        title: Text(
          vm.formatDate(journal.date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        subtitle: const Text(
          'Journal entry',
          style: TextStyle(
            fontSize: 12,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'insight') {
              _openInsight(
                aiMood: journal.aiMood,
                aiInsight: journal.aiInsight,
                source: 'history',
              );
              return;
            }

            if (journal.id != null && journal.id!.isNotEmpty) {
              _showDeleteJournalConfirmation(journal.id!, userId);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'insight',
              child: Text('View Insight'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => _openInsight(
          aiMood: journal.aiMood,
          aiInsight: journal.aiInsight,
          source: 'history',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 42,
            color: _muted,
          ),
          const SizedBox(height: 10),
          const Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete a check-in or journal to see it here.',
            style: TextStyle(
              fontSize: 13,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openInsight({
    required String? aiMood,
    required String? aiInsight,
    required String source,
  }) {
    Navigator.pushNamed(
      context,
      '/insight',
      arguments: {
        'aiMood': (aiMood == null || aiMood.isEmpty)
            ? 'No mood detected'
            : aiMood,
        'aiInsight': (aiInsight == null || aiInsight.isEmpty)
            ? 'No insight available'
            : aiInsight,
        'source': source,
      },
    );
  }

  void _showDeleteCheckinConfirmation(String checkinId, String userId) {
    final vm = Provider.of<HistoryViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Check-in?'),
        content: const Text(
          'This entry will be removed permanently.',
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
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteJournalConfirmation(String journalId, String userId) {
    final vm = Provider.of<HistoryViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal?'),
        content: const Text(
          'This entry will be removed permanently.',
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
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
