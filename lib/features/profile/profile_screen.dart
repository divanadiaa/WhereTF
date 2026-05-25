import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../premium/premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color textLight = const Color(0xFF9E8E78);
  final Color gold = const Color(0xFFD8B36A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildStats(),

                  const SizedBox(height: 18),

                  _buildPremiumCard(),

                  const SizedBox(height: 22),

                  _sectionTitle('Account'),
                  _accountCard(),

                  const SizedBox(height: 22),

                  _sectionTitle('Support'),
                  _supportCard(),

                  const SizedBox(height: 28),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showBottomMessage(
                          'Logged out successfully',
                        );
                      },
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        48,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.settings_rounded,
              color: bgCream,
              size: 22,
            ),
          ),

          CircleAvatar(
            radius: 38,
            backgroundColor:
                const Color(0xFFE1C9A8),
            child: Text(
              'P',
              style: GoogleFonts.inter(
                color: darkBrown,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Pelangi',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'pelangi@email.com',
            style: GoogleFonts.inter(
              color:
                  Colors.white.withOpacity(0.72),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: () {
                _showBottomMessage(
                  'Edit profile clicked',
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color:
                      bgCream.withOpacity(0.5),
                ),
                foregroundColor: bgCream,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                  color: bgCream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard(
          'Circles',
          '0',
          Icons.near_me_outlined,
        ),

        const SizedBox(width: 10),

        _statCard(
          'Members',
          '0',
          Icons.groups_rounded,
        ),

        const SizedBox(width: 10),

        _statCard(
          'Days Active',
          '1',
          Icons.access_time_rounded,
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE7D5C2),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: gold,
              size: 18,
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PremiumScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  gold.withOpacity(0.18),
              child: Icon(
                Icons
                    .workspace_premium_rounded,
                color: gold,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'whereTF Premium',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Unlock 7-day location history',
                    style: GoogleFonts.inter(
                      color: Colors.white
                          .withOpacity(0.72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: bgCream,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuTile(
            icon:
                Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              _showBottomMessage(
                'Edit profile clicked',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _supportCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuTile(
            icon:
                Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {
              _showBottomMessage(
                'Help & Support clicked',
              );
            },
          ),

          _divider(),

          _menuTile(
            icon:
                Icons.info_outline_rounded,
            title: 'About whereTF',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: bgCream,
                shape:
                    const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                builder: (_) {
                  return Padding(
                    padding:
                        const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'whereTF',
                          style:
                              GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color: darkBrown,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          'whereTF is a real-time location tracking application designed to help families and friends stay connected safely.',
                          textAlign:
                              TextAlign.center,
                          style:
                              GoogleFonts.inter(
                            color: textLight,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(
                            height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      leading: Icon(
        icon,
        color: gold,
        size: 20,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: darkBrown,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: textLight,
        size: 14,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 10,
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color:
              darkBrown.withOpacity(0.75),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: bgCream,
      borderRadius:
          BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFE7D5C2),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: const Color(0xFFE7D5C2),
      indent: 48,
    );
  }

  void _showBottomMessage(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}