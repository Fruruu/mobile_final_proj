import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'paper_painter.dart';
import '../../view_models/journal_view_model.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/frosted_app_bar.dart';
import '../../theme/app_colors.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  final _journalController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  bool _isFocused = false;

  static const Color _bg = Color(0xFFF4EFF1);
  static const Color _primary = AppColors.primaryPink;
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);
  static const Color _paperBg = Color(0xFFFFFBF5);
  static const Color _paperBorder = Color(0xFFE8E3DC);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  String _formattedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekday = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  int get _wordCount {
    final text = _journalController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Widget _buildBackground() {
    return Positioned(
      top: -110,
      left: -90,
      right: -90,
      child: Container(
        height: 560,
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
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeIn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _paperBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 26,
                color: _text,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'What\'s on your '),
                TextSpan(
                  text: 'mind',
                  style: TextStyle(
                    color: _primary,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' today?'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a moment to breathe and reflect.',
            style: TextStyle(
              fontSize: 14,
              color: _muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: _primary),
              const SizedBox(width: 6),
              Text(
                _formattedDate(),
                style: TextStyle(
                  fontSize: 13,
                  color: _primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_journalController.text.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(_wordCount),
              '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
              style: TextStyle(
                fontSize: 12,
                color: _muted.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton(JournalViewModel vm, String? userId) {
    final bool disabled = vm.isLoading || _journalController.text.isEmpty;

    return AnimatedScale(
      scale: disabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: disabled
            ? null
            : () async {
                if (userId != null) {
                  final exists = await vm.todayJournalExists(userId);
                  if (exists && context.mounted) {
                    _showUpdateDialog(vm);
                  } else if (!exists && context.mounted) {
                    await vm.submitJournal(userId);
                    _navigateToInsights(vm);
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: disabled ? _primary.withOpacity(0.4) : _primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          shadowColor: _primary.withOpacity(0.3),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? 2 : 0,
          ),
        ),
        child: vm.isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Saving your thoughts...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Save & Get Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                ],
              ),
      ),
    );
  }

  void _showUpdateDialog(JournalViewModel vm) {
    final user = Supabase.instance.client.auth.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              if (user != null) {
                await vm.submitJournal(user.id);
                _navigateToInsights(vm);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _navigateToInsights(JournalViewModel vm) {
    if (!vm.success || !context.mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);
    final user = Supabase.instance.client.auth.currentUser;
    final screenHeight = MediaQuery.of(context).size.height;
    final paperCardHeight = screenHeight < 700 ? 360.0 : 430.0;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Journal'),
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + FrostedAppBar.barHeight + 8,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header
                _buildHeader(),
                const SizedBox(height: 20),

                // Date strip + word count
                _buildDateStrip(),
                const SizedBox(height: 12),

                // Paper card — rebuild with vm in scope
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: _paperBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isFocused
                          ? _primary.withOpacity(0.3)
                          : _paperBorder.withOpacity(0.6),
                      width: _isFocused ? 1.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isFocused
                            ? _primary.withOpacity(0.08)
                            : const Color(0xFFE8E3DC).withOpacity(0.8),
                        blurRadius: _isFocused ? 28 : 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top accent line
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primary.withOpacity(0.0),
                                _primary.withOpacity(_isFocused ? 0.5 : 0.2),
                                _primary.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: paperCardHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: PaperPainter(
                                    paperColor: _paperBg,
                                    lineColor: _paperBorder,
                                    shadowColor: _primary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Opacity(
                                opacity: 0.08,
                                child: Transform.rotate(
                                  angle: -0.15,
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 60,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ),
                            TextField(
                              controller: _journalController,
                              focusNode: _focusNode,
                              minLines: null,
                              maxLines: null,
                              expands: true,
                              onChanged: (value) {
                                vm.setJournalText(value);
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Write freely — this is your space...',
                                hintStyle: TextStyle(
                                  color: _primary.withOpacity(0.45),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.65,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.fromLTRB(
                                    24, 24, 24, 24),
                              ),
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 15.5,
                                height: 1.65,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom bar (only when typing)
                      if (_journalController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.04),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: _paperBorder.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: _primary.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI will analyze your entry',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _muted.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$_wordCount ${_wordCount == 1 ? 'word' : 'words'} · ${_journalController.text.length} chars',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _primary.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Error message
                if (vm.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.red),
                        const SizedBox(width: 6),
                        Text(
                          vm.errorMessage,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Save button
                _buildSaveButton(vm, user?.id),

                const SizedBox(height: 12),

                // Prompt nudge when empty
                if (_journalController.text.isEmpty)
                  Center(
                    child: Text(
                      'Even a few sentences can reveal a lot 💭',
                      style: TextStyle(
                        fontSize: 12,
                        color: _muted.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
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
