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
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            moodAssetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        subtitle: Text(
          'Check-in · $moodLabel',
          style: const TextStyle(
            fontSize: 13,
            color: _muted,
            fontWeight: FontWeight.w600,
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
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_horiz_rounded, color: Color(0xFF6A6768)),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
