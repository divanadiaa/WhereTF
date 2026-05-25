import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wheretf/core/widgets/custom_widgets.dart';
import 'package:wheretf/features/main/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoginMode;

  const AuthScreen({
    super.key,
    this.isLoginMode = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const Color primaryColor = Color(0xFF5C5240);
  static const Color bgColor = Color(0xFFF5F0EA);
  static const Color textDark = Color(0xFF3B3025);
  static const Color textLight = Color(0xFF9E8E78);
  static const Color primaryLight = Color(0xFFD6C9B6);

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLoginMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  TextStyle _font({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: _WavyBottomClipper(),
              child: Container(
                height: 260,
                width: double.infinity,
                color: primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                        ),
                        child: Center(
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'whereTF',
                        style: _font(
                          size: 28,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isLogin
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Log In',
                                style: _font(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: isLogin ? Colors.white : textLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isLogin
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Sign Up',
                                style: _font(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: !isLogin ? Colors.white : textLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (!isLogin) ...[
                    Text(
                      'Create account',
                      style: _font(
                        size: 24,
                        weight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join Circlee and start connecting.',
                      style: _font(
                        size: 14,
                        color: textLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomTextField(
                    controller: _emailController,
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 16),

                  if (!isLogin) ...[
                    CustomTextField(
                      controller: _phoneController,
                      hint: 'Phone Number',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  if (isLogin) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: _font(
                            size: 14,
                            color: const Color(0xFFB89D7A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Use 8+ characters with a mix of letters, numbers & symbols.',
                      style: _font(
                        size: 12,
                        color: textLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _submitAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              isLogin ? 'Log In' : 'Create Account',
                              style: _font(
                                size: 16,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: primaryLight),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          isLogin ? 'or' : 'or continue with',
                          style: _font(
                            size: 14,
                            color: textLight,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: primaryLight),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.g_mobiledata,
                            color: textDark,
                            size: 28,
                          ),
                          label: Text(
                            'Google',
                            style: _font(
                              size: 14,
                              weight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.apple,
                            color: textDark,
                            size: 28,
                          ),
                          label: Text(
                            'Apple',
                            style: _font(
                              size: 14,
                              weight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: isLogin
                            ? 'By signing up you agree to our '
                            : 'By creating an account you agree to our\n',
                        style: _font(
                          size: 12,
                          color: textLight,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: _font(
                              size: 12,
                              color: textLight,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: _font(
                              size: 12,
                              color: textLight,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: _font(
                            size: 14,
                            color: textLight,
                          ),
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: _font(
                                size: 14,
                                weight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavyBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, size.height - 70);

    path.cubicTo(
      size.width * 0.30,
      size.height + 10,
      size.width * 0.65,
      size.height - 90,
      size.width,
      size.height - 55,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}