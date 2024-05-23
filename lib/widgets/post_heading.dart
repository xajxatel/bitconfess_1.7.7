import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class PostHeadingWidget extends StatelessWidget {
  final String message;
  final String username;
  final DateTime timeSent;

  const PostHeadingWidget({
    super.key,
    required this.message,
    required this.username,
    required this.timeSent,
  });

  @override
  Widget build(BuildContext context) {
    Size size = getUserScreenSize(context);
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 20, left: 10, right: 10),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ShapeDecoration(
          color: Colors.grey[900],
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40))),
      height: size.height / 7,
      child: SingleChildScrollView(
        child: Container(
          decoration: ShapeDecoration(
              color: Colors.grey[900],
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(40))),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: size.width / 1.5,
                    child: AutoSizeText(
                      username,
                      style: GoogleFonts.anonymousPro(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      maxFontSize: 16,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: size.width / 10,
                    child: AutoSizeText(
                      formatRelativeTime(timeSent.toLocal()),
                      style: GoogleFonts.anonymousPro(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxFontSize: 16,
                      maxLines: 2,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              AutoSizeText(
                message,
                style: GoogleFonts.anonymousPro(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,

                  // Use Lato font
                ),
                maxFontSize: 20,
                minFontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
