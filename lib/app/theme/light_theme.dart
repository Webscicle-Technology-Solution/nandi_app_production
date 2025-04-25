import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  
  // Primary color
  primaryColor: Color(0xFFE99C05),
  hintColor: Color(0xFFF4AE00),
  primaryColorDark: const Color(0xFF0C0C0C),
  primaryColorLight: const Color(0xFFf2f2f2),

  // Updated button theme with gradient (Using ElevatedButton style)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF4AE00),  // Ensure the button itself is transparent to show gradient
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      textStyle: GoogleFonts.poppins(color: Colors.black ,fontSize: 14), 
      iconColor: Colors.black,
      foregroundColor: Colors.black
    ).copyWith(
      backgroundColor: WidgetStateProperty.all(Color(0xFFF4AE00)), // Ensure background is transparent
    ),
  ),

  // Background and Scaffold background color
  scaffoldBackgroundColor: Color(0xFFF2F2F2),

  // Text theme updates
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.poppins( fontWeight: FontWeight.w400, color: const Color(0xFF0C0C0C)), // Use bodyText1 instead of bodyLarge
    bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: const Color(0xFF0C0C0C)), // Use bodyText2 instead of bodyMedium
    titleLarge: GoogleFonts.poppins(color: const Color(0xFF0C0C0C)), // Example for titles and headers
  ),

  // Icon theme update
  iconTheme: const IconThemeData(
    color: Color(0xFF0C0C0C),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF2F2F2),
    unselectedItemColor: Color(0xFFA3A3A3),
    selectedItemColor: Color(0xFFE99C05), // Highlight selected item with primary color
  ),

  // Use AppBar theme to ensure consistent look and feel
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Ensure the app bar color matches the primary color
    titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 20),
  ),
  inputDecorationTheme: InputDecorationTheme(
  focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color: Color(0xFFF4AE00),width: 1,),borderRadius: BorderRadius.circular(10)),
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFA3A3A3),width: 1,),borderRadius: BorderRadius.circular(10)),
  labelStyle: GoogleFonts.poppins(color: Color(0xFFA3A3A3),fontSize: 12),
  hintStyle: GoogleFonts.poppins(color: Color(0xFFA3A3A3),fontSize: 12),
),

);

