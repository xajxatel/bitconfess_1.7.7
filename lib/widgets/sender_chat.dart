import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SenderChat extends StatelessWidget {
  final LobbyChat message;

  const SenderChat({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Size size = getUserScreenSize(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints:
                BoxConstraints(maxWidth: size.width / 1.3, minWidth: 40),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade800, // You can customize the color
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  message.username,
                  style: GoogleFonts.anonymousPro(
                    color: Colors.white60, // White text color
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxFontSize: 16,
                  minFontSize: 12,
                ),
                const SizedBox(
                  height: 5,
                ),
                AutoSizeText(
                  message.message,
                  style: GoogleFonts.anonymousPro(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    // Use Lato font
                  ),
                  maxFontSize: 16,
                  minFontSize: 12,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          AutoSizeText(
            " ${formatRelativeTime(message.time)}",
            style: GoogleFonts.anonymousPro(
              color: Colors.white60, // White text color
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
            maxFontSize: 16,
            minFontSize: 12,
          ),
        ],
      ),
    );
  }
}
