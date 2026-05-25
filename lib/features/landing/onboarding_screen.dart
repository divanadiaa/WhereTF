import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wheretf/core/widgets/custom_widgets.dart';
import 'package:wheretf/features/auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Know where they are",
      "subtitle": "See your family and friends on a\nprivate map in real-time.",
    },
    {
      "title": "Create your Circle",
      "subtitle":
          "Organize your people into private\nCircles for family, friends, or work.",
    },
    {
      "title": "Review any moment",
      "subtitle":
          "Look back at where everyone has been\nwith detailed location history.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  TextStyle _textStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEFE3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: index == 0
                              ? _buildSlide1Illustration()
                              : index == 1
                                  ? _buildSlide2Illustration()
                                  : _buildSlide3Illustration(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: _textStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2416),
                          ),
                        ),
                        if (index == 2) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5975A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Premium',
                                  style: _textStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: _textStyle(
                            fontSize: 15,
                            color: const Color(0xFF9A8B7A),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                text: _currentPage == onboardingData.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: () {
                  if (_currentPage < onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthScreen(isLoginMode: false),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthScreen(isLoginMode: true),
                  ),
                );
              },
              child: Text(
                'I already have an account',
                style: _textStyle(
                  fontSize: 15,
                  color: const Color(0xFF9A8B7A),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide1Illustration() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Container(
              width: 310,
              height: 220,
              color: const Color(0xFFEDE0CF),
              child: CustomPaint(painter: _MapPainter()),
            ),
          ),
          Positioned(
            top: 18,
            left: 128,
            child: _MapAvatarPin(name: 'Mom', color: const Color(0xFF6B5740)),
          ),
          Positioned(
            top: 68,
            right: 26,
            child: _MapAvatarPin(name: 'Emma', color: const Color(0xFF8B7060)),
          ),
          Positioned(
            top: 88,
            left: 20,
            child: _MapAvatarPin(name: 'Dad', color: const Color(0xFFB08060)),
          ),
          Positioned(
            bottom: 48,
            left: 52,
            child: _MapAvatarPin(name: 'Jake', color: const Color(0xFF5C4A35)),
          ),
          Positioned(
            bottom: 48,
            right: 52,
            child: _MapAvatarPin(name: 'Sara', color: const Color(0xFF9A8070)),
          ),
          Positioned(
            top: 143,
            left: 146,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3D3020),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2Illustration() {
    final avatars = [
      {
        'name': 'Anna',
        'color': const Color(0xFF8B7355),
        'top': 0.05,
        'left': 0.38,
      },
      {
        'name': 'Sara',
        'color': const Color(0xFFB08060),
        'top': 0.25,
        'left': 0.08,
      },
      {
        'name': 'Tom',
        'color': const Color(0xFF6B7B5A),
        'top': 0.25,
        'left': 0.70,
      },
      {
        'name': 'Jake',
        'color': const Color(0xFF5C4A35),
        'top': 0.60,
        'left': 0.10,
      },
      {
        'name': 'Mia',
        'color': const Color(0xFF4A7090),
        'top': 0.60,
        'left': 0.68,
      },
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        _DashedCircle(size: 280, color: const Color(0xFFD4B896)),
        _DashedCircle(size: 190, color: const Color(0xFFD4B896)),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8D5C0).withOpacity(0.6),
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3D3020),
          ),
          child: const Icon(
            Icons.share_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        ...avatars.map((a) {
          return Positioned(
            top: 300 * (a['top'] as double),
            left: 300 * (a['left'] as double),
            child: _AvatarBubble(
              name: a['name'] as String,
              color: a['color'] as Color,
            ),
          );
        }),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF3D3020), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Family Circle · 5 members',
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2416),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide3Illustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _DashedCircle(size: 280, color: const Color(0xFFD4B896)),
        _DashedCircle(size: 175, color: const Color(0xFFD4B896)),
        const Positioned(
          top: 100,
          right: 20,
          child: _TimelineDot(isActive: true),
        ),
        const Positioned(
          top: 130,
          left: 60,
          child: _TimelineDot(isActive: false),
        ),
        Positioned(
          top: 60,
          left: 115,
          child: Column(
            children: [
              _buildTimeLabel('Yesterday'),
              const SizedBox(height: 4),
              const _TimelineDot(isActive: false),
            ],
          ),
        ),
        Positioned(
          bottom: 70,
          left: 30,
          child: Column(
            children: [
              _buildTimeLabel('2 days ago'),
              const SizedBox(height: 4),
              const _TimelineDot(isActive: false),
            ],
          ),
        ),
        Positioned(
          bottom: 52,
          left: 70,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB5975A).withOpacity(0.5),
            ),
          ),
        ),
        const Positioned(
          top: 18,
          left: 130,
          child: _CircleAvatar2(color: Color(0xFFB08060), size: 44),
        ),
        const Positioned(
          top: 80,
          left: 28,
          child: _CircleAvatar2(color: Color(0xFF6B7B5A), size: 44),
        ),
        const Positioned(
          top: 140,
          left: 10,
          child: _CircleAvatar2(color: Color(0xFFB5A0D0), size: 44),
        ),
        const Positioned(
          bottom: 80,
          left: 0,
          child: _CircleAvatar2(color: Color(0xFF5C4A35), size: 40),
        ),
        const Positioned(
          bottom: 60,
          right: 0,
          child: _AnnaTooltip(),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, color: Color(0xFF3D3020), size: 18),
                const SizedBox(width: 8),
                Text(
                  '30-day location history',
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2416),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: _textStyle(
          fontSize: 11,
          color: const Color(0xFF6B5740),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 8,
      width: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? const Color(0xFF3D3020)
            : const Color(0xFFD4B896),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFD4BC9E)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadThinPaint = Paint()
      ..color = const Color(0xFFD4BC9E)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final greenPaint = Paint()
      ..color = const Color(0xFFCDDFB8).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final blockPaint = Paint()
      ..color = const Color(0xFFD6C4A8).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.28,
          size.height * 0.32,
          size.width * 0.18,
          size.height * 0.28,
        ),
        const Radius.circular(6),
      ),
      greenPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.55,
          size.height * 0.40,
          size.width * 0.16,
          size.height * 0.22,
        ),
        const Radius.circular(5),
      ),
      greenPaint,
    );

    final blocks = [
      Rect.fromLTWH(
        size.width * 0.50,
        size.height * 0.55,
        size.width * 0.14,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.62,
        size.width * 0.10,
        size.height * 0.12,
      ),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(3)),
        blockPaint,
      );
    }

    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.48),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.70, size.height),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.50, 0),
      Offset(size.width * 0.85, size.height * 0.55),
      roadThinPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.70),
      Offset(size.width * 0.90, size.height * 0.62),
      roadThinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapAvatarPin extends StatelessWidget {
  final String name;
  final Color color;

  const _MapAvatarPin({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF3D3020).withOpacity(0.88),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DashedCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DashedCirclePainter(color: color),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const dashCount = 40;
    const dashAngle = 3.14159 * 2 / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashAngle;
        final sweepAngle = dashAngle * 0.6;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AvatarBubble extends StatelessWidget {
  final String name;
  final Color color;

  const _AvatarBubble({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF3D3020).withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAvatar2 extends StatelessWidget {
  final Color color;
  final double size;

  const _CircleAvatar2({
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool isActive;

  const _TimelineDot({
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 28 : 22,
      height: isActive ? 28 : 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: isActive ? const Color(0xFF3D3020) : const Color(0xFFB5975A),
          width: isActive ? 2.5 : 1.8,
        ),
      ),
      child: Center(
        child: Container(
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF3D3020) : const Color(0xFFB5975A),
          ),
        ),
      ),
    );
  }
}

class _AnnaTooltip extends StatelessWidget {
  const _AnnaTooltip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3020),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B7060),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anna',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                'Central Park, NY',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Now · 2 hrs ago · Yesterday',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}