import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'dashboard_screen.dart';
import 'ai_reports_screen.dart';
import 'journal_screen.dart';

const List<double> _weeklyMoods = [2, 3, 3, 1, 3, 2, 3];
const List<double> _monthlyMoods = [
  2, 3, 1, 2, 3, 3, 2, 1, 3, 2, 3, 3, 1, 2, 3,
  3, 2, 3, 1, 2, 3, 2, 3, 3, 2, 1, 3, 2, 3, 3,
];

class _SparklinePainter extends CustomPainter {
  final List<double> current;
  final List<double> previous;

  _SparklinePainter({required this.current, required this.previous});

  Path _buildPath(List<double> data, Size size) {
    if (data.isEmpty) return Path();
    final dx = size.width / (data.length - 1);
    final path = Path();
    double _y(double v) =>
        size.height - ((v - 1) / 2) * size.height * 0.8 - size.height * 0.1;
    path.moveTo(0, _y(data[0]));
    for (int i = 1; i < data.length; i++) {
      final x0 = (i - 1) * dx;
      final x1 = i * dx;
      final y0 = _y(data[i - 1]);
      final y1 = _y(data[i]);
      path.cubicTo(x0 + dx / 2, y0, x1 - dx / 2, y1, x1, y1);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final prevPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final prevPath = _buildPath(previous, size);
    final dashPath = Path();
    for (final m in prevPath.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        dashPath.addPath(m.extractPath(dist, dist + 6), Offset.zero);
        dist += 12;
      }
    }
    canvas.drawPath(dashPath, prevPaint);

    final currPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(_buildPath(current, size), currPaint);

    canvas.drawPath(
      _buildPath(current, size),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final dx = size.width / (current.length - 1);
    double _y(double v) =>
        size.height - ((v - 1) / 2) * size.height * 0.8 - size.height * 0.1;
    final lastX = (current.length - 1) * dx;
    final lastY = _y(current.last);
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = const Color(0xFF7C3AED));
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.current != current || old.previous != previous;
}

class _MoodHeader extends StatefulWidget {
  const _MoodHeader();

  @override
  State<_MoodHeader> createState() => _MoodHeaderState();
}

class _MoodHeaderState extends State<_MoodHeader>
    with SingleTickerProviderStateMixin {
  bool _isMonthly = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }


  String get _moodLabel {
    final data = _isMonthly ? _monthlyMoods : _weeklyMoods;
    final avg = data.reduce((a, b) => a + b) / data.length;
    if (avg >= 2.5) return 'Feeling Great';
    if (avg >= 1.8) return 'Doing Okay';
    return 'Rough Patch';
  }

  String get _avgPercent {
    final data = _isMonthly ? _monthlyMoods : _weeklyMoods;
    final avg = data.reduce((a, b) => a + b) / data.length;
    return '${((avg / 3) * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final current = _isMonthly ? _monthlyMoods : _weeklyMoods;
    final previous = current.map((v) => (v - 0.5).clamp(1.0, 3.0)).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCE93D8),
            Color(0xFFBA68C8),
            Color(0xFF9575CD),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x55E1BEE7), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.purple[50]!.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _moodLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'AVERAGE MOOD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _avgPercent,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fade,
                  child: SizedBox(
                    height: 80,
                    child: CustomPaint(
                      painter: _SparklinePainter(current: current, previous: previous),
                      size: const Size(double.infinity, 80),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _legendDot(Colors.white, 'current ${_isMonthly ? 'month' : 'week'}'),
                    const SizedBox(width: 16),
                    _legendDot(Colors.white.withOpacity(0.4), 'previous ${_isMonthly ? 'month' : 'week'}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF7C3AED) : Colors.white,
            ),
          ),
        ),
      );

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
        ],
      );
}

enum ProfileMenu { profile, settings, logout }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _handleProfileAction(BuildContext context, ProfileMenu value) {
    switch (value) {
      case ProfileMenu.profile:
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Profile'),
              content: Text('Email: ${user.email ?? 'N/A'}'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              ],
            ),
          );
        }
        break;
      case ProfileMenu.settings:
        Navigator.pushNamed(context, '/settings');
        break;
      case ProfileMenu.logout:
        Provider.of<AuthViewModel>(context, listen: false).logout().then((_) {
          Navigator.of(context).pushReplacementNamed('/login');
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('MoodPath'),
        backgroundColor: const Color(0xFFBB86FC),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<ProfileMenu>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) => _handleProfileAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: ProfileMenu.profile, child: ListTile(leading: Icon(Icons.person), title: Text('Profile'))),
              const PopupMenuItem(value: ProfileMenu.settings, child: ListTile(leading: Icon(Icons.settings), title: Text('Settings'))),
              const PopupMenuItem(value: ProfileMenu.logout, child: ListTile(leading: Icon(Icons.logout), title: Text('Logout'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentIndex == 0 ? const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _MoodHeader()) : const SizedBox.shrink(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                DashboardScreen(),
                AIReportsScreen(),
                JournalScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'AI Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Journal'),
        ],
      ),
    );
  }
}
