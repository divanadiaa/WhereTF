import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/home_screen.dart';
import '../circle/circle_screen.dart';
import '../history/location_history_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);

  final List<Widget> pages = const [
    HomeScreen(),
    CircleScreen(),
    LocationHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        height: 82,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.map_rounded, 'Home', 0),
            _nav(Icons.groups_rounded, 'Circles', 1),
            _nav(Icons.access_time_rounded, 'History', 2),
            _nav(Icons.person_outline_rounded, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int index) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? bgCream : bgCream.withOpacity(0.55),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: active ? bgCream : bgCream.withOpacity(0.55),
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}