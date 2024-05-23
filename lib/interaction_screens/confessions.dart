import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfessionsScreen extends ConsumerStatefulWidget {
  final String? username;
  const ConfessionsScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<ConfessionsScreen> createState() => _ConfessionsScreenState();
}

class _ConfessionsScreenState extends ConsumerState<ConfessionsScreen> {
  final TextEditingController _messageController = TextEditingController();
  double lineHeight = 18; // Height of each line in the text input

  double _calculateLineHeight(
      BuildContext context, BoxConstraints constraints) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _messageController.text,
        style: GoogleFonts.anonymousPro(fontSize: 20),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: constraints.maxWidth - 40);

    final cursorOffset = _messageController.selection.extentOffset;
    final cursorPosition = textPainter.getOffsetForCaret(
      TextPosition(offset: cursorOffset),
      Rect.fromLTWH(0, 0, constraints.maxWidth - 40, double.infinity),
    );

    return cursorPosition.dy;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int hourlyConfessionCount = 0;
  int hourlyLimit = 3; // Change this to your desired daily limit

  @override
  void initState() {
    super.initState();
    _loadHourlyConfessionCount();
  }

  Future<void> _loadHourlyConfessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now();
    final lastSavedTime =
        DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastSavedTime') ?? 0);

    // Calculate the difference in hours
    final hoursDifference = currentTime.difference(lastSavedTime).inHours;

    if (hoursDifference < 1) {
      // If less than an hour has passed, load the confession count
      setState(() {
        hourlyConfessionCount = prefs.getInt('hourlyConfessionCount') ?? 0;
      });
    }
  }

  Future<void> _saveHourlyConfessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now();
    await prefs.setInt('lastSavedTime', currentTime.millisecondsSinceEpoch);
    await prefs.setInt('hourlyConfessionCount', hourlyConfessionCount);
  }

  Future<void> _postConfession() async {
    if (hourlyConfessionCount >= hourlyLimit) {
      _showLimitExceededDialog();
    } else {
      // Proceed with posting the confession

      if (_messageController.text.trim().isEmpty) {
        if (context.mounted) {
          showSnackBar(context: context, content: 'Empty message!!');
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final currentTime = DateTime.now();
        final lastSavedTime = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('lastSavedTime') ?? 0);

        // Calculate the difference in hours
        final hoursDifference = currentTime.difference(lastSavedTime).inHours;

        if (hoursDifference < 1) {
          // If less than an hour has passed, increment the confession count
          setState(() {
            hourlyConfessionCount++;
          });
        } else {
          // If it's been more than an hour, reset the confession count
          setState(() {
            hourlyConfessionCount = 1;
          });
        }

        // Save the updated confession count
        await _saveHourlyConfessionCount();
        if (context.mounted) {
          ref.read(authServiceProvider).saveUserPost(
                message: _messageController.text,
                context: context,
              );
        }
      }
      _messageController.clear();
    }
  }

  void _showLimitExceededDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Hourly limit reached',
            style: GoogleFonts.anonymousPro(
              color: const Color.fromARGB(211, 244, 67, 54),
            ),
          ),
          content: Text('You can post a maximum of 3 confessions per hour',
              style: GoogleFonts.anonymousPro(color: Colors.grey.shade400)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text(
                'Ok',
                style:
                    GoogleFonts.anonymousPro(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'new confession',
                            curve: Curves.ease,
                            textStyle: GoogleFonts.anonymousPro(
                              color: Colors.grey.shade500,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            speed: const Duration(milliseconds: 300),
                          ),
                        ],
                        repeatForever: true,
                        isRepeatingAnimation: true,
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      lineHeight = _calculateLineHeight(context, constraints);
                      return Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            color: Colors.black,
                            child: TextField(
                              cursorColor: Colors.white,
                              maxLength: 5000,
                              controller: _messageController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Write something_',
                                hintStyle: GoogleFonts.anonymousPro(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                ),
                              ),
                              style: GoogleFonts.anonymousPro(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: lineHeight,
                            bottom: lineHeight + 16,
                            child: Container(
                              width: 2,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 50),
                    child: CustomButton(
                      buttonWidth: 0.4,
                      color: primaryColor,
                      onTap: () async {
                        _postConfession();
                      },
                      text: 'Post',
                    ),
                  ),
                ],
              ),
            )));
  }
}
