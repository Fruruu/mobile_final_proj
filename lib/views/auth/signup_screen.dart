import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_visuals.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthday;
  bool _obscurePassword = true;

  static const Color _bg = AppColors.white;
  static const Color _primary = AppColors.primaryPink;
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF5B5658);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const AuthGradientBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: AnimatedMoodPathLogo(
                          interval: Duration(seconds: 2),
                        ),
                      ),
                    ),
                    const Text(
                      'Mood Path',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FafoSans',
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your account to start your path.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _text,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 6),
                      child: Text(
                        'Email Address',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'hello@example.com',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    const SizedBox(height: 14),

                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 6),
                      child: Text(
                        'Name (optional)',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildInputField(
                      controller: _nameController,
                      hintText: 'Alex Smith',
                      keyboardType: TextInputType.name,
                      obscureText: false,
                    ),
                    const SizedBox(height: 14),

                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 6),
                      child: Text(
                        'Phone (optional)',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildInputField(
                      controller: _phoneController,
                      hintText: '+1 555 123 4567',
                      keyboardType: TextInputType.phone,
                      obscureText: false,
                    ),
                    const SizedBox(height: 14),

                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 6),
                      child: Text(
                        'Birthday (optional)',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime(now.year - 18, now.month, now.day),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setState(() {
                            _birthday = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, color: _muted),
                            const SizedBox(width: 12),
                            Text(
                              _birthday == null
                                  ? 'Select your birthday'
                                  : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _birthday == null ? _muted : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 6),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildInputField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      keyboardType: TextInputType.text,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _muted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vm.errorMessage.isNotEmpty)
                      Text(
                        vm.errorMessage,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.24),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                final success = await vm.signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  name: _nameController.text.trim(),
                                  birthday: _birthday,
                                  phone: _phoneController.text.trim(),
                                );
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: vm.isLoading
                            ? const Text(
                                'Creating Account...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFACADAD)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
