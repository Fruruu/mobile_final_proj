import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import 'overlay_action_menu.dart';

class EntryCheckinCard extends StatelessWidget {
  const EntryCheckinCard({
    super.key,
    required this.dateLabel,
    required this.moodLabel,
    required this.moodAssetPath,
    required this.onTap,
    required this.onMenuSelected,
  });

  final String dateLabel;
  final String moodLabel;
  final String moodAssetPath;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            moodAssetPath,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        subtitle: Text(
          'Check-in · $moodLabel',
          style: const TextStyle(
            fontSize: 12,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: OverlayActionMenu<String>(
          tooltip: 'Entry actions',
          width: 222,
          verticalGap: 10,
          onSelected: onMenuSelected,
          items: const [
            OverlayMenuItem<String>(
              value: 'insight',
              label: 'View Insight',
              icon: Icons.visibility_rounded,
              showDividerAfter: true,
            ),
            OverlayMenuItem<String>(
              value: 'delete',
              label: 'Delete',
              icon: Icons.delete_rounded,
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ],
          child: const Icon(Icons.more_horiz_rounded, color: Color(0xFF6A6768)),
        ),
        onTap: onTap,
      ),
    );
  }
}
