import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

//COLORS
const Color blackColor = Colors.black;
const Color whiteColor = Colors.white;
Color primaryColor = Colors.purple;

const String primaryColorKey = 'primaryColor';

// Function to get the primary color from SharedPreferences
Future<Color> getPrimaryColor() async {
  final prefs = await SharedPreferences.getInstance();
  final savedColor = prefs.getInt(primaryColorKey);
  return Color(savedColor ?? Colors.purple.value);
}

// Function to set and save the primary color in SharedPreferences
Future<void> setPrimaryColor(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(primaryColorKey, color.value);
}

// Function to cycle through available colors
Color cyclePrimaryColor(Color currentColor) {
  final availableColors = [
    Colors.purple,
    Colors.green.shade700,
    Colors.red.shade900,
    Colors.blue.shade900,
    Colors.pink,
    Colors.yellow.shade600
  ];

  final currentColorValue =
      currentColor.value; // Get the integer value of the current color

  for (int i = 0; i < availableColors.length; i++) {
    if (availableColors[i].value == currentColorValue) {
      final nextIndex = (i + 1) % availableColors.length;
      return availableColors[nextIndex];
    }
  }

  // If the current color is not found, return the default color
  return Colors.purple;
}

//UTILTY FUNCTIONS

Size getUserScreenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 800),
      content: Text(
        content,
        style: GoogleFonts.anonymousPro(fontSize: 15),
      )));
}

String formatRelativeTime(DateTime timeSent) {
  final now = DateTime.now();
  final difference = now.difference(timeSent);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays == 1) {
    return '1d';
  } else {
    return '${difference.inDays}d';
  }
}
