import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/user_avatar.dart';
import '../../data/models/circle_member.dart';

class MemberTodayHistoryScreen extends StatelessWidget {
  const MemberTodayHistoryScreen({
    super.key,
    required this.member,
  });

  final CircleMember member;

  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2D183D);
    const bgCream = Color(0xFFFAF8F3);
    const textLight = Color(0xFF7F708A);

    return Scaffold(
      backgroundColor: bgCream,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 42, 18, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: darkBrown,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: darkBrown,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Terakhir diperbarui belum tersedia',
                        style: GoogleFonts.inter(
                          color: textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 12,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.wheretf.app',
                      maxZoom: 19,
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -38,
                  child: Container(
                    height: 84,
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                    decoration: const BoxDecoration(
                      color: bgCream,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 14,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Text(
                      member.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: UserAvatar(
                        user: member.user,
                        initials: member.initials,
                        radius: 40,
                        backgroundColor: const Color(0xFF8FC7D4),
                        foregroundColor: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
              children: [
                Text(
                  'Hari ini',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                _InfoCard(
                  title: 'Riwayat hari ini belum tersedia',
                  subtitle:
                      'Belum ada aktivitas lokasi yang tercatat untuk hari ini. Coba lagi setelah lokasi anggota diperbarui.',
                  icon: Icons.route_rounded,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: member.contactLabel ?? member.displayRole,
                  subtitle: '${member.displayRole} - ${member.displayStatus}',
                  icon: Icons.person_pin_circle_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E7F8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Color(0xFF7E42D8),
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7F708A),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
