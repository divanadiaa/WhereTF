import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/user_avatar.dart';
import '../../data/models/circle_member.dart';
import '../../data/models/circle_summary.dart';
import '../../data/services/api_client.dart';
import '../../state/session_controller.dart';
import 'join_circle_screen.dart';
import '../landing/welcome_screen.dart';

class CircleScreen extends StatefulWidget {
  const CircleScreen({super.key});

  @override
  State<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends State<CircleScreen> {
  int? _lastRequestedCircleId;

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF5B4D41);
    final Color backgroundCream = const Color(0xFFFAE8D2);
    final Color lightCream = const Color(0xFFFFF7ED);
    final Color textLight = const Color(0xFF9E8E78);
    final session = context.watch<SessionController>();
    final currentCircle = session.currentCircle;

    _requestMembersIfNeeded(session);

    if (!session.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _redirectToLogin();
        }
      });
    }

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

              const SizedBox(height: 28),

              Expanded(
                child: currentCircle == null
                    ? _buildEmptyState(
                        backgroundCream: backgroundCream,
                        lightCream: lightCream,
                        textLight: textLight,
                      )
                    : _buildCurrentCircleState(
                        context: context,
                        currentCircle: currentCircle,
                        lightCream: lightCream,
                        textLight: textLight,
                      ),
              ),

              _buildActionButtons(
                context: context,
                darkBrown: darkBrown,
                session: session,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestMembersIfNeeded(SessionController session) {
    final circleId = session.currentCircle?.id;
    if (circleId == null) {
      _lastRequestedCircleId = null;
      return;
    }

    if (session.isLoadingCircleMembers ||
        session.hasCircleMembersForCurrentCircle) {
      _lastRequestedCircleId = circleId;
      return;
    }

    if (_lastRequestedCircleId == circleId) {
      return;
    }

    _lastRequestedCircleId = circleId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<SessionController>()
          .refreshCircleMembers(allowFailure: true);
    });
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _openJoinCircle(BuildContext context) async {
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const JoinCircleScreen(),
      ),
    );

    if (!context.mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _leaveCircle(BuildContext context) async {
    final session = context.read<SessionController>();

    try {
      final message = await session.leaveCircle();
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on UnauthorizedException {
      if (!context.mounted) {
        return;
      }

      _redirectToLogin();
    } on ApiException catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _showCreateUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create circle belum tersedia di backend.'),
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

  Widget _buildCurrentCircleState({
    required BuildContext context,
    required CircleSummary currentCircle,
    required Color lightCream,
    required Color textLight,
  }) {
    final session = context.watch<SessionController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightCream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentCircle.displayName,
              style: GoogleFonts.inter(
                color: const Color(0xFF2D2318),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite code: ${currentCircle.referalCode}',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currentCircle.isOwnedBy(session.currentUser?.id)
                  ? 'This is your default circle.'
                  : "You are currently active in another member's circle.",
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _buildMembersSection(
              context: context,
              session: session,
              currentCircle: currentCircle,
              textLight: textLight,
            ),
            if (session.canLeaveCurrentCircle) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: session.isUpdatingCircle
                      ? null
                      : () => _leaveCircle(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF5B4D41),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    session.isUpdatingCircle
                        ? 'Leaving...'
                        : 'Leave current circle',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5B4D41),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection({
    required BuildContext context,
    required SessionController session,
    required CircleSummary currentCircle,
    required Color textLight,
  }) {
    final error = session.circleMembersError;
    final members = session.circleMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Members',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2D2318),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              session.isLoadingCircleMembers
                  ? 'Loading...'
                  : '${members.length}',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: session.isLoadingCircleMembers
                  ? null
                  : () => context
                      .read<SessionController>()
                      .refreshCircleMembers(allowFailure: true),
              icon: Icon(
                Icons.refresh_rounded,
                color: textLight,
                size: 18,
              ),
              tooltip: 'Refresh members',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (session.isLoadingCircleMembers && members.isEmpty)
          _buildMembersLoading(textLight)
        else if (error != null)
          _buildMembersError(
            context: context,
            message: error,
            textLight: textLight,
          )
        else if (members.isEmpty)
          _buildMembersEmpty(textLight)
        else
          Column(
            children: [
              for (int index = 0; index < members.length; index++) ...[
                _buildMemberTile(
                  member: members[index],
                  currentCircle: currentCircle,
                  textLight: textLight,
                ),
                if (index != members.length - 1)
                  const Divider(
                    height: 18,
                    color: Color(0xFFE7D5C2),
                  ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildMembersLoading(Color textLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading circle members...',
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersError({
    required BuildContext context,
    required String message,
    required Color textLight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tidak bisa memuat anggota circle.',
            style: GoogleFonts.inter(
              color: const Color(0xFF2D2318),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context
                .read<SessionController>()
                .refreshCircleMembers(allowFailure: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersEmpty(Color textLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        'Belum ada member yang bisa ditampilkan untuk circle ini.',
        style: GoogleFonts.inter(
          color: textLight,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required CircleMember member,
    required CircleSummary currentCircle,
    required Color textLight,
  }) {
    final isOwner = member.hasOwnerRole || currentCircle.isOwnedBy(member.userId);
    final roleLabel = isOwner ? 'Owner' : member.displayRole;
    final avatarColor =
        isOwner ? const Color(0xFFD8B36A) : const Color(0xFFE5CCAD);
    final avatarTextColor =
        isOwner ? const Color(0xFF2D2318) : const Color(0xFF5B4D41);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          user: member.user,
          initials: member.initials,
          radius: 22,
          backgroundColor: avatarColor,
          foregroundColor: avatarTextColor,
          fontSize: 14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF2D2318),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                member.contactLabel ?? 'No email or phone',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMemberChip(
                    label: roleLabel,
                    background: isOwner
                        ? const Color(0xFFFFE7B3)
                        : const Color(0xFFF1E7DA),
                    foreground: const Color(0xFF5B4D41),
                  ),
                  _buildMemberChip(
                    label: member.displayStatus,
                    background: member.status.toLowerCase() == 'active'
                        ? const Color(0xFFE3F2DF)
                        : const Color(0xFFF3E1DD),
                    foreground: const Color(0xFF5B4D41),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberChip({
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
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
    required SessionController session,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _showCreateUnavailable(context),
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
            onPressed: session.isUpdatingCircle
                ? null
                : () => _openJoinCircle(context),
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
