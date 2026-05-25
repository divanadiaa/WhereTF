import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_circle_screen.dart';
import 'join_circle_screen.dart';

class CircleScreen extends StatelessWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF5B4D41);
    final Color backgroundCream = const Color(0xFFFAE8D2);
    final Color lightCream = const Color(0xFFFFF7ED);
    final Color textLight = const Color(0xFF9E8E78);

    return Scaffold(
      backgroundColor: backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
          child: Column(
            children: [
              Text(
                'My Circles',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2D2318),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              _buildSearchBox(textLight),

              const Spacer(),

              _buildEmptyState(
                backgroundCream: backgroundCream,
                lightCream: lightCream,
                textLight: textLight,
              ),

              const Spacer(),

              _buildActionButtons(
                context: context,
                darkBrown: darkBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(Color textLight) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E5D5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: textLight.withOpacity(0.7),
            size: 20,
          ),

          const SizedBox(width: 8),

          Text(
            'Search circles...',
            style: GoogleFonts.inter(
              color: textLight.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required Color backgroundCream,
    required Color lightCream,
    required Color textLight,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _dashedCircle(112),
              _dashedCircle(82),
              _dashedCircle(50),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5CCAD),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: backgroundCream,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.remove_rounded,
                  color: lightCream,
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'No circles yet',
          style: GoogleFonts.inter(
            color: const Color(0xFF2D2318),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Create or join a circle to start tracking\nlocations with your people',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: textLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _dashedCircle(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: const Color(0xFFD9B98E),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required Color darkBrown,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCircleScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              'Create New Circle',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (_) => const JoinCircleScreen(),
        ),
      );
    },
    style: OutlinedButton.styleFrom(
      side: BorderSide(
        color: darkBrown,
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
    ),
    child: Text(
      'Join with invite code',
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
    ),
  ),
),
      ],
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
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius = size.width / 2;

    const int dashCount = 38;
    const double dashAngle = 3.14159 * 2 / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
          i * dashAngle,
          dashAngle * 0.58,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}