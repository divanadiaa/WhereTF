import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../../data/models/app_user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.user,
    this.initials,
    this.photoUrl,
    required this.radius,
    required this.backgroundColor,
    required this.foregroundColor,
    this.fontSize,
    this.fontWeight = FontWeight.w800,
  });

  final AppUser? user;
  final String? initials;
  final String? photoUrl;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final resolvedPhotoUrl = _clean(photoUrl) ?? user?.displayPhotoUrl;
    if (resolvedPhotoUrl != null) {
      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: Image.network(
            resolvedPhotoUrl,
            fit: BoxFit.cover,
            headers: _networkHeaders(resolvedPhotoUrl),
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _fallbackAvatar(),
          ),
        ),
      );
    }

    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        _fallbackInitials,
        style: GoogleFonts.inter(
          color: foregroundColor,
          fontSize: fontSize ?? radius * 0.72,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  String get _fallbackInitials {
    final value = _clean(initials) ?? user?.initials ?? '?';
    return value;
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  Map<String, String>? _networkHeaders(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';
    final configuredHost =
        Uri.tryParse(AppConfig.baseUrl)?.host.toLowerCase() ?? '';

    if (host.contains('ngrok') || configuredHost.contains('ngrok')) {
      return const {'ngrok-skip-browser-warning': 'true'};
    }

    return null;
  }
}
