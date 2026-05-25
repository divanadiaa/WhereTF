import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteCodeScreen extends StatelessWidget {
  final String circleName;
  final String inviteCode;

  const InviteCodeScreen({
    super.key,
    required this.circleName,
    required this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF5B4D41);
    final Color bgCream = const Color(0xFFFFF8F0);
    final Color cardCream = const Color(0xFFFFF3E6);
    final Color textLight = const Color(0xFF9E8E78);
    final Color gold = const Color(0xFFD8B36A);

    final String fullCode = 'FIND-$inviteCode';

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: darkBrown,
            size: 20,
          ),
        ),
        title: Text(
          'Invite Member',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 34, 22, 28),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFFFE7C5),
              child: Icon(
                Icons.person_outline_rounded,
                color: gold,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              circleName.isEmpty ? 'No role selected' : circleName,
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    'Your invite code',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullCode,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expires in 24 hours',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: fullCode),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invite code copied'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      label: Text(
                        'Copy Code',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SHARE VIA',
                style: GoogleFonts.inter(
                  color: darkBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _shareButton(
                  color: const Color(0xFF25D366),
                  icon: Icons.chat_rounded,
                ),
                const SizedBox(width: 12),
                _shareButton(
                  color: const Color(0xFF2AABEE),
                  icon: Icons.send_rounded,
                ),
                const SizedBox(width: 12),
                _shareButton(
                  color: darkBrown,
                  icon: Icons.sms_rounded,
                ),
                const SizedBox(width: 12),
                _shareButton(
                  color: cardCream,
                  icon: Icons.link_rounded,
                  iconColor: darkBrown,
                  borderColor: const Color(0xFFE6D3BC),
                ),
                const SizedBox(width: 12),
                _shareButton(
                  color: cardCream,
                  icon: Icons.more_horiz_rounded,
                  iconColor: darkBrown,
                  borderColor: const Color(0xFFE6D3BC),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2E4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6D3BC),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: gold,
                    size: 16,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Anyone with this code can join your Family Circle',
                      style: GoogleFonts.inter(
                        color: darkBrown,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Add a role instead',
              style: GoogleFonts.inter(
                color: const Color(0xFFC59D74),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareButton({
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
    Color? borderColor,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null
            ? Border.all(
                color: borderColor,
              )
            : null,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 19,
      ),
    );
  }
}