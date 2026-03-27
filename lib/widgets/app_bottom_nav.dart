import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const List<_NavItemData> _items = [
    _NavItemData(label: 'Home', icon: Icons.home_rounded, route: '/home'),
    _NavItemData(
      label: 'Check-In',
      icon: Icons.check_box_rounded,
      route: '/checkin',
    ),
    _NavItemData(
      label: 'Journal',
      icon: Icons.edit_note,
      route: '/journal',
    ),
    _NavItemData(
      label: 'Entries',
      icon: Icons.history_rounded,
      route: '/history',
    ),
    _NavItemData(
      label: 'Reports',
      icon: Icons.bar_chart_rounded,
      route: '/report',
    ),
  ];

  static const Color _activeBg = AppColors.primaryPink;
  static const Color _inactive = AppColors.primaryPink;
  static const Color _shellShadow = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: _shellShadow,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _onTap(context, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 21,
                          color: selected ? AppColors.white : _inactive,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? AppColors.white : _inactive,
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Navigator.pushReplacementNamed(context, _items[index].route);
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
