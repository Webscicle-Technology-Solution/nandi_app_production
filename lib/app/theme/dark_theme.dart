import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark, // Set brightness to dark

  
  // Primary color for dark theme
  primaryColor: const Color(0xFFE99C05),  // You can choose a different primary color for dark theme if desired
  hintColor: const Color(0xFFF4AE00), // You can adjust the hint color as needed
  primaryColorDark: const Color(0xFFF2F2F2),
  primaryColorLight: const Color(0xFF0c0c0c),

  
  // Updated button theme with gradient (Using ElevatedButton style)

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:Color(0xFFF4AE00),  // Transparent background to show gradient
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      textStyle: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13),  // Text color for dark theme buttons
      iconColor: Colors.white,
        foregroundColor: Colors.white
      ).copyWith(
      backgroundColor: WidgetStateProperty.all(Color(0xFFF4AE00)), // Ensure background is transparent
    ),
  ),

  // Background and Scaffold background color for dark theme
  scaffoldBackgroundColor: const Color(0xFF121212),  // Dark background color

  // Text theme updates for dark theme (light text on dark background)
  textTheme:  TextTheme(
    bodyLarge: GoogleFonts.poppins( fontWeight: FontWeight.w400,color: Color(0xFFF2F2F2)), // Light text color for body text
    bodyMedium: GoogleFonts.poppins( fontWeight: FontWeight.w500,color: Color(0xFFF2F2F2)), // Light text color for secondary body text
    titleLarge: GoogleFonts.poppins(color: Color(0xFFF2F2F2)), // Light color for titles
  ),

  // Icon theme update for dark mode
  iconTheme: const IconThemeData(
    color: Color(0xFFF2F2F2),  // Light icon color for visibility in dark mode
  ),
  // Bottom Navigation Bar Theme for dark mode
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF121212),  // Dark background for bottom navigation
    unselectedItemColor: Color(0xFFA3A3A3), // Lighter color for unselected items
    selectedItemColor: Color(0xFFE99C05), // Highlight selected item with primary color
  ),

  // AppBar Theme for dark mode
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Dark background for the AppBar
    titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20), // Light text for titles
  ),
  inputDecorationTheme: InputDecorationTheme(
  focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color: Color(0xFFF4AE00),width: 1,),borderRadius: BorderRadius.circular(10)),
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFA3A3A3),width: 1,),borderRadius: BorderRadius.circular(10)),
  labelStyle: GoogleFonts.poppins(color: Color(0xFFA3A3A3),fontSize: 12),
  hintStyle: GoogleFonts.poppins(color: Color(0xFFA3A3A3),fontSize: 12),
),
  
);

