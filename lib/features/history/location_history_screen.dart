import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../premium/premium_screen.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color cardCream = const Color(0xFFF5EEE6);
  final Color textLight = const Color(0xFF9E8E78);

  final bool isPremium = false;

  int selectedDateIndex = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              'Location History',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'No active circle',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            if (!isPremium) _buildUpgradeCard(),
            const SizedBox(height: 18),
            _buildDateSelector(),
            const SizedBox(height: 18),
            _buildMapPreview(),
            const SizedBox(height: 18),
            _buildEmptyHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Color(0xFFD8B36A),
            size: 28,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock 7-Day\nHistory',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'See where your circle has been',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8E8D2),
              foregroundColor: darkBrown,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Upgrade — Rp19.900/mo',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();

    final dates = List.generate(7, (index) {
      final date = now.subtract(
        Duration(days: 6 - index),
      );

      final dayName = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][date.weekday - 1];

      return {
        'day': dayName,
        'date': date.day.toString(),
      };
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(dates.length, (index) {
        final item = dates[index];
        final bool isSelected = selectedDateIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDateIndex = index;
            });
          },
          child: Container(
            width: 39,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? darkBrown : const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? darkBrown : const Color(0xFFE8D4BD),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['day'].toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isSelected ? Colors.white70 : textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['date'].toString(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      width: double.infinity,
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8D4BD),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            isPremium ? 'Route will appear here' : 'No routes yet',
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history_rounded,
            color: Color(0xFFD8B36A),
            size: 40,
          ),

          const SizedBox(height: 16),

          Text(
            isPremium
                ? 'Your 7-day location history will appear here'
                : 'Your location history will appear here',
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isPremium
                ? 'Start moving to record your routes'
                : 'Upgrade to premium to unlock 7-day history',
            style: GoogleFonts.inter(
              color: textLight.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}