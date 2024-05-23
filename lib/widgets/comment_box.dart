import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentBox extends StatelessWidget {
  final String commentText;
  final String commenterName;
  final DateTime timeSent;

  const CommentBox({
    super.key,
    required this.commentText,
    required this.commenterName,
    required this.timeSent,
  });

  @override
  Widget build(BuildContext context) {
    Size size = getUserScreenSize(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            commentText,
            style: GoogleFonts.anonymousPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,

              // Use Lato font
            ),
            maxFontSize: 26,
            minFontSize: 12,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: size.width / 1.5,
                child: AutoSizeText(
                  commenterName,
                  style: GoogleFonts.anonymousPro(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  maxFontSize: 14,
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
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  maxFontSize: 15,
                  minFontSize: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
