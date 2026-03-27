import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OverlayMenuItem<T> {
  const OverlayMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.black,
    this.fontWeight = FontWeight.w500,
    this.showDividerAfter = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final Color color;
  final FontWeight fontWeight;
  final bool showDividerAfter;
}

class OverlayActionMenu<T> extends StatelessWidget {
  const OverlayActionMenu({
    super.key,
    required this.child,
    required this.items,
    required this.onSelected,
    this.tooltip,
    this.offset = const Offset(0, 8),
    this.width = 220,
    this.verticalGap = 8,
  });

  final Widget child;
  final List<OverlayMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String? tooltip;
  final Offset offset;
  final double width;
  final double verticalGap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      offset: offset,
      color: AppColors.white,
      elevation: 10,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      menuPadding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: math.max(4, verticalGap / 2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.black.withOpacity(0.08)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        final popupEntries = <PopupMenuEntry<T>>[];

        for (final item in items) {
          popupEntries.add(
            PopupMenuItem<T>(
              value: item.value,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: item.fontWeight,
                      color: item.color,
                    ),
                  ),
                  const Spacer(),
                  Icon(item.icon, size: 18, color: item.color),
                ],
              ),
            ),
          );

          if (item.showDividerAfter) {
            popupEntries.add(PopupMenuDivider(height: verticalGap * 2));
          }
        }

        return popupEntries;
      },
      child: child,
    );
  }
}
