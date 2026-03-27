import 'package:flutter/material.dart';

class CheckListItemCard extends StatelessWidget {
  const CheckListItemCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
    this.isCompleted = false,
    this.onTap,
  });

  final String leading;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gradientColors = isCompleted
        ? <Color>[const Color(0xFFDADADA), const Color(0xFFC9C9C9)]
        : <Color>[startColor, endColor];
    final textColor = isCompleted
        ? const Color(0xFF5F5F5F)
        : const Color(0xFF231F20);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF231F20).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                leading,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
