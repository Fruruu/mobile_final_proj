import 'package:flutter/material.dart';
import '../../models/journal_checkin.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  String? _editingId;
  DateTime _selectedDate = DateTime.now();

  // Static sample data
  List<JournalEntry> _journals = [
    JournalEntry(
      id: '1',
      userId: '',
      date: DateTime.now().subtract(const Duration(days: 1)),
      journalText: 'Feeling reflective today. The app is working great!',
      aiMood: '😊',
    ),
    JournalEntry(
      id: '2',
      userId: '',
      date: DateTime.now().subtract(const Duration(days: 3)),
      journalText: 'Had a productive day. Looking forward to tomorrow.',
      aiMood: '👍',
    ),
    JournalEntry(
      id: '3',
      userId: '',
      date: DateTime.now().subtract(const Duration(days: 7)),
      journalText: 'Started using this journal. Excited about tracking my mood!',
      aiMood: '✨',
    ),
    JournalEntry(
      id: '4',
      userId: '',
      date: DateTime.now().subtract(const Duration(days: 14)),
      journalText: 'First entry. This seems like a nice place to write thoughts.',
      aiMood: '📝',
    ),
  ];
  bool _isLoading = false;

  // Soft note background colors to cycle through
  final List<Color> _noteColors = const [
    Color(0xFFF3E8FF), // light violet
    Color(0xFFEBF4FF), // light blue-purple
    Color(0xFFE8F0FF), // light indigo
    Color(0xFFF0E8FF), // light purple
    Color(0xFFF8F0FF), // lavender
    Color(0xFFE0F2FE), // light cyan-purple
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showJournalForm({JournalEntry? entry}) async {
    _editingId = entry?.id;
    _editController.text = entry?.journalText ?? '';
    _journalController.clear();
    _selectedDate = entry?.date ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F7FF),
                Color(0xFFF3E8FF),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x557C3AED),
                  blurRadius: 16,
                  offset: Offset(0, -4))
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _editingId == null ? '✏️  New Entry' : '✏️  Edit Entry',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Date picker row
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setSheetState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.brown.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.purple.shade400),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Text field styled like a lined notepad
              TextField(
                controller:
                    _editingId == null ? _journalController : _editController,
                maxLines: 6,
                style: TextStyle(
                    fontSize: 15, color: Colors.brown.shade900, height: 1.6),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts here...',
                  hintStyle: TextStyle(color: Colors.brown.shade300),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.brown.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.brown.shade400, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.brown.shade400)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final text = (_editingId == null
                              ? _journalController.text
                              : _editController.text)
                          .trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter some text')));
                        return;
                      }
                      try {
                        final journal = JournalEntry(
                          id: _editingId ??
                              DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                          userId: '',
                          date: _selectedDate,
                          journalText: text,
                          aiMood: '😊',
                        );

                        if (_editingId == null) {
                          if (mounted) {
                            setState(() {
                              _journals.insert(0, journal);
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Entry saved locally!')),
                          );
                          _journalController.clear();
                        } else {
                          if (mounted) {
                            setState(() {
                              final idx = _journals
                                  .indexWhere((e) => e.id == _editingId);
                              if (idx != -1) _journals[idx] = journal;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Entry updated locally!')),
                          );
                          _editController.clear();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(_editingId == null ? 'Save' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteJournal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      if (mounted) {
        setState(() => _journals.removeWhere((e) => e.id == id));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted locally')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'My Journal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6D28D9),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                'Your thoughts, your space.',
                style:
                    TextStyle(fontSize: 13, color: Colors.purple.shade300),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _journals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.book_outlined,
                                    size: 64, color: Colors.brown.shade200),
                                const SizedBox(height: 12),
                                Text(
                                  'No entries yet.\nTap + to write your first one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.brown.shade300,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _journals.length,
                            itemBuilder: (context, index) {
                              final entry = _journals[index];
                              final color =
                                  _noteColors[index % _noteColors.length];
                              final dateStr =
                                  entry.date.toString().split(' ')[0];

                              return _NoteCard(
                                entry: entry,
                                color: color,
                                dateStr: dateStr,
                                onTap: () => _showJournalForm(entry: entry),
                                onEdit: () => _showJournalForm(entry: entry),
                                onDelete: () => _deleteJournal(entry.id!),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJournalForm(),
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('New Entry',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  void dispose() {
    _journalController.dispose();
    _editController.dispose();
    super.dispose();
  }
}

class _NoteCard extends StatelessWidget {
  final JournalEntry entry;
  final Color color;
  final String dateStr;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.entry,
    required this.color,
    required this.dateStr,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final text = entry.journalText ?? '';
    final preview = text.length > 120 ? '${text.substring(0, 120)}…' : text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Tape strip decoration at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.aiMood ?? '📝',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: Colors.brown.shade300, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit')
                              ])),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red))
                              ])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade800,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}