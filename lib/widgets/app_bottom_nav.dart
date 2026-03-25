import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const List<String> _routes = [
    '/home',
    '/checkin',
    '/journal',
    '/history',
    '/report',
  ];

  static const Color _primary = Color(0xFF75525B);
  static const Color _activeBg = Color(0xFFFFD1DC);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.16),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onTap(context, index),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: _primary,
            unselectedItemColor: const Color(0xFF767777),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _buildItem(Icons.home, 'Home'),
              _buildItem(Icons.check_circle_outline, 'Check-in'),
              _buildItem(Icons.edit_note, 'Journal'),
              _buildItem(Icons.history, 'History'),
              _buildItem(Icons.bar_chart, 'Reports'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label) {
    const iconSize = 20.0;
    const labelStyle = TextStyle(
      color: Color(0xFF767777),
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );

    final verticalItem = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(height: 2),
        Text(label, style: labelStyle),
      ],
    );

    return BottomNavigationBarItem(
      icon: verticalItem,
      activeIcon: DecoratedBox(
        decoration: BoxDecoration(
          color: _activeBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: IconTheme(
            data: const IconThemeData(color: _primary, size: iconSize),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              child: verticalItem,
            ),
          ),
        ),
      ),
      label: '',
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Navigator.pushReplacementNamed(context, _routes[index]);
  }
}
