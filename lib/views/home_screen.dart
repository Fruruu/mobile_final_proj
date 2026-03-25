import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view_models/home_view_model.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;

  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _primarySoft = Color(0xFFFFD1DC);
  static const Color _text = Color(0xFF2D2F2F);
  static const Color _muted = Color(0xFF5A5C5C);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final vm = Provider.of<HomeViewModel>(context, listen: false);
        vm.loadDashboard(user.id);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);
    final today = vm.todayCheckin;
    final hasCheckin = today != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'MoodPath',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: _bg,
        foregroundColor: _muted,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await vm.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${vm.getUserName()}',
              style: const TextStyle(
                fontSize: 16,
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 34,
                  color: _text,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                children: [
                  TextSpan(text: 'How does your inner world\nfeel '),
                  TextSpan(
                    text: 'today?',
                    style: TextStyle(
                      color: _primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF4F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'CURRENT STREAK',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🔥 ${vm.streakCount} ${vm.streakCount == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasCheckin
                        ? 'Great consistency. Your streak is alive today.'
                        : 'Complete today\'s check-in to protect your streak.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _muted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkin');
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Log Mood',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/report');
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFB2E4FB),
                            foregroundColor: const Color(0xFF014154),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'View Trends',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Today\'s Snapshot',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 10),
            if (hasCheckin)
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: [
                  _buildMetricTile(
                    label: 'Mood',
                    value: '${today.userMood ?? 0}/5',
                    icon: vm.getMoodEmoji(today.userMood),
                    bg: const Color(0xFFE7F6FD),
                  ),
                  _buildMetricTile(
                    label: 'Sleep',
                    value: '${today.sleepHours?.toStringAsFixed(1) ?? '0.0'}h',
                    icon: '😴',
                    bg: const Color(0xFFEFF0FF),
                  ),
                  _buildMetricTile(
                    label: 'Exercise',
                    value: today.exercised ? 'Yes' : 'No',
                    icon: '💪',
                    bg: const Color(0xFFFEEFCF),
                  ),
                  _buildMetricTile(
                    label: 'Water',
                    value: '${today.waterGlasses ?? 0} cups',
                    icon: '💧',
                    bg: const Color(0xFFDDF1FF),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD8DADA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No check-in recorded yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start your day by logging mood, sleep, and habits.',
                      style: TextStyle(color: _muted),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkin');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                      ),
                      child: const Text('Open Check-in'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            const Text(
              'Your Daily Anchors',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildAnchorCard(
                  title: 'Journal',
                  subtitle: 'Reflect on your day',
                  icon: Icons.edit_note,
                  bg: const Color(0xFFDDFCDE),
                  iconColor: const Color(0xFF47624B),
                  onTap: () => Navigator.pushNamed(context, '/journal'),
                ),
                const SizedBox(height: 10),
                _buildAnchorCard(
                  title: 'Hydration',
                  subtitle: '${today?.waterGlasses ?? 0}/8 glasses',
                  icon: Icons.water_drop,
                  bg: const Color(0xFFB2E4FB),
                  iconColor: const Color(0xFF2F6275),
                  onTap: () => Navigator.pushNamed(context, '/checkin'),
                ),
                const SizedBox(height: 10),
                _buildAnchorCard(
                  title: 'Check-in',
                  subtitle: 'Track your mood',
                  icon: Icons.wb_sunny,
                  bg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFB45309),
                  onTap: () => Navigator.pushNamed(context, '/checkin'),
                ),
                const SizedBox(height: 10),
                _buildAnchorCard(
                  title: 'History',
                  subtitle: 'See your progress',
                  icon: Icons.timeline,
                  bg: const Color(0xFFE7E8E8),
                  iconColor: _text,
                  onTap: () => Navigator.pushNamed(context, '/history'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Pattern',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You are on a ${vm.streakCount}-day streak. Keep your daily check-ins consistent to unlock deeper insights.',
                    style: const TextStyle(color: _muted, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/report');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _primary,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Explore Insights',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              vm.getUserEmail(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF767777)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String icon,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _text,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnchorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
