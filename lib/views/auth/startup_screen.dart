import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/auth_visuals.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const AuthGradientBackdrop(),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _goToLogin(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: AnimatedMoodPathLogo(
                        size: 112,
                        iconSize: 104,
                        interval: Duration(seconds: 2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Mood Path',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FafoSans',
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPink,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track your mood, reflect, and grow one day at a time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5B5658),
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'tap anywhere on the screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8F8B8C),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
