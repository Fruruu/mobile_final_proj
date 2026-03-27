import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'overlay_action_menu.dart';

class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  static const Color _primaryPink = AppColors.primaryPink;
  static const Color _black = AppColors.black;
  static const double barHeight = 84;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: barHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      surfaceTintColor: const Color.fromARGB(0, 0, 0, 0),
      forceMaterialTransparency: true,
      foregroundColor: _black,
      titleSpacing: showBackButton ? 0 : 12,
      leading: showBackButton
          ? IconButton(
              onPressed:
                  onBackPressed ??
                  () => Navigator.pushReplacementNamed(context, '/history'),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryPink,
              ),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: _primaryPink,
          fontFamily: 'FafoSans',
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _ProfileMenuButton(),
        ),
      ],
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(129, 255, 209, 209).withOpacity(0.52),
              border: Border(
                bottom: BorderSide(color: _black.withOpacity(0.08), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: _black.withOpacity(0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProfileAction { settings, logout }

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton();

  @override
  Widget build(BuildContext context) {
    return OverlayActionMenu<_ProfileAction>(
      tooltip: 'Profile menu',
      offset: const Offset(0, 8),
      width: 228,
      verticalGap: 10,
      onSelected: (action) async {
        if (action == _ProfileAction.logout) {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      },
      items: const [
        OverlayMenuItem<_ProfileAction>(
          value: _ProfileAction.settings,
          label: 'Settings',
          icon: Icons.settings,
          color: AppColors.black,
          fontWeight: FontWeight.w500,
          showDividerAfter: true,
        ),
        OverlayMenuItem<_ProfileAction>(
          value: _ProfileAction.logout,
          label: 'Logout',
          icon: Icons.logout_rounded,
          color: AppColors.red,
          fontWeight: FontWeight.w600,
        ),
      ],
      child: const _ProfileImageContainer(),
    );
  }
}

class _ProfileImageContainer extends StatelessWidget {
  const _ProfileImageContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryPink,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 20, color: AppColors.white),
    );
  }
}
