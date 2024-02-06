import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kartoyun/components/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange; // Yeni eklenen satır

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange, // Yeni eklenen satır
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.acikyesil,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: GNav(
          //backgroundColor: MyColors.acikyesil,
          color: Colors.black,
          gap: 8,
          padding: const EdgeInsets.all(16),
          activeColor: MyColors.yesil,
          tabBackgroundColor: MyColors.acikyesil,
          selectedIndex: selectedIndex, // Yeni eklenen satır
          tabs: [
            GButton(
              icon: Icons.message_outlined,
              text: "Sohbetler",
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                color: MyColors.yesil,
                //fontWeight: FontWeight.bold,
              ),
              onPressed: () => onTabChange(0), // Yeni eklenen satır
            ),
            GButton(
              icon: Icons.games,
              text: "Kart Oyna",
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                color: MyColors.yesil,
                //fontWeight: FontWeight.bold,
              ),
              onPressed: () => onTabChange(1), // Yeni eklenen satır
            ),
            GButton(
              icon: Icons.person_rounded,
              text: "Profil",
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                color: MyColors.yesil,
                //fontWeight: FontWeight.bold,
              ),
              onPressed: () => onTabChange(2), // Yeni eklenen satır
            ),
          ],
        ),
      ),
    );
  }
}
