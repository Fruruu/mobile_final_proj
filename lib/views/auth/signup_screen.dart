import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _primary = Color(0xFF75525B);
  static const Color _primaryDim = Color(0xFF684650);
  static const Color _text = Color(0xFF2D2F2F);
  static const Color _muted = Color(0xFF5A5C5C);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -110,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x55F0C3CE),
              ),
            ),
          ),
          Positioned(
            top: 240,
            right: -95,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x44DDFCDE),
              ),
            ),
          ),
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
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 76,
                        height: 76,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_primary, Color(0xFFFFD1DC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF0C3CE).withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: _text,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start tracking your mood and habits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
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
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primary, _primaryDim],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
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
                                );
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFFFFEFF1),
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: const Color(0xFFFFEFF1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: _muted, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: _primary, fontWeight: FontWeight.w800),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}