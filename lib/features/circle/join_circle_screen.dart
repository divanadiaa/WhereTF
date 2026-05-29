import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/services/api_client.dart';
import '../../state/session_controller.dart';
import '../landing/welcome_screen.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  final TextEditingController inviteCodeController = TextEditingController();

  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color cardCream = const Color(0xFFFFF3E6);
  final Color textLight = const Color(0xFF9E8E78);
  final Color gold = const Color(0xFFD8B36A);

  @override
  void initState() {
    super.initState();
    inviteCodeController.addListener(_normalizeInviteCodeInput);
  }

  @override
  void dispose() {
    inviteCodeController.removeListener(_normalizeInviteCodeInput);
    inviteCodeController.dispose();
    super.dispose();
  }

  void _normalizeInviteCodeInput() {
    final normalized = inviteCodeController.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    final limited = normalized.length > 5
        ? normalized.substring(0, 5)
        : normalized;

    if (inviteCodeController.text == limited) {
      return;
    }

    inviteCodeController.value = TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }

  Future<void> joinCircle() async {
    final code = inviteCodeController.text.trim();
    final session = context.read<SessionController>();

    if (code.isEmpty) {
      _showMessage('Invite code wajib diisi.');
      return;
    }

    if (code.length != 5) {
      _showMessage('Invite code harus tepat 5 karakter.');
      return;
    }

    try {
      final message = await session.joinCircle(code);
      if (!mounted) {
        return;
      }

      Navigator.pop(context, message);
    } on UnauthorizedException {
      _redirectToLogin();
    } on ApiValidationException catch (e) {
      _showMessage(e.message);
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _redirectToLogin() {
    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final isLoading = session.isUpdatingCircle;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF1E7DA),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: darkBrown,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Join a Circle',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 48, 22, 28),
        child: Column(
          children: [
            SizedBox(
              width: 110,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1E7DA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2D1BA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: gold,
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            Text(
              'Enter invite code',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Ask the circle owner for their invite code',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: inviteCodeController,
              maxLength: 5,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              style: GoogleFonts.inter(
                color: darkBrown,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 5,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'ABCDE',
                hintStyle: GoogleFonts.inter(
                  color: textLight.withOpacity(0.65),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
                filled: true,
                fillColor: cardCream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0B884),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: darkBrown,
                    width: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Code is not case sensitive',
              style: GoogleFonts.inter(
                color: textLight.withOpacity(0.8),
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 70),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : joinCircle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  isLoading ? 'Joining...' : 'Join Circle',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'By joining you agree to share your location with all\nmembers of this circle',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
