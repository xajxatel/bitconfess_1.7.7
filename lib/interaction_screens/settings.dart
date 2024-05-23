import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/firebase_service/screens/landing.dart';
import 'package:bitsconfess/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.anonymousPro(color: whiteColor),
          ),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: GoogleFonts.anonymousPro(color: Colors.grey.shade400)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text(
                'Cancel',
                style:
                    GoogleFonts.anonymousPro(color: Colors.white, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                // Call the delete account method from AuthService
                ref.read(authServiceProvider).deleteAccount(context);
                Navigator.pop(context); // Close the confirmation dialog
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                    (route) =>
                        false); // Navigate back to the previous screen (SettingsScreen)
              },
              child: Text(
                'Delete',
                style:
                    GoogleFonts.anonymousPro(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = getUserScreenSize(context);
    return Scaffold(
      backgroundColor: blackColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height / 4,
            ),
            CustomButton(
              buttonWidth: 0.75,
              onTap: () => _confirmDeleteAccount(context, ref),
              text: 'Delete my account',
              color: const Color.fromARGB(211, 244, 67, 54),
            ),
            SizedBox(height: size.height / 3),
            Consumer(
              builder: (context, ref, child) {
                AsyncValue<int> totalUserCount =
                    ref.watch(totalUserCountStreamProvider);

                return totalUserCount.when(
                  data: (count) => Text(
                    'User Count: $count',
                    style: GoogleFonts.anonymousPro(
                      color: whiteColor,
                    ),
                  ),
                  loading: () => const Loader(),
                  error: (error, stackTrace) =>
                      const Text('Error fetching user count'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
