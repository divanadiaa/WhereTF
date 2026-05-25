import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color textLight = const Color(0xFF9E8E78);

  int selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9D9D9D),
      body: Stack(
        children: [
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.72,
            maxChildSize: 0.92,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: bgCream,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2BFA9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: darkBrown,
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFD8B36A)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'whereTF Premium',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Unlock the full experience',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 22),
                    _benefit('7-day location history for you and friends'),
                    _benefit('View friends’ full daily routes'),
                    _benefit('Location history export'),
                    _benefit('Priority support'),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _planCard(
                            index: 0,
                            title: 'Monthly',
                            price: 'Rp 19.900',
                            subtitle: '/ month',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _planCard(
                            index: 1,
                            title: 'Yearly',
                            price: 'Rp 199.000',
                            subtitle: '/ year',
                            badge: 'Save 17%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'PAY WITH',
                      style: GoogleFonts.inter(
                        color: darkBrown,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _payment('GoPay'),
                        const SizedBox(width: 8),
                        _payment('OVO'),
                        const SizedBox(width: 8),
                        _payment('Credit Card'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Subscribe Now',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Cancel anytime · Renews automatically',
                        style: GoogleFonts.inter(color: textLight, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Restore purchase',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC59D74),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFFD8B36A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    String? badge,
  }) {
    final active = selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? darkBrown : bgCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2CDB7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                      color: active ? Colors.white : darkBrown,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                Text(price,
                    style: GoogleFonts.inter(
                      color: active ? Colors.white : Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    )),
                Text(subtitle,
                    style: GoogleFonts.inter(
                      color: active ? Colors.white70 : textLight,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8B36A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _payment(String text) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2CDB7)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}