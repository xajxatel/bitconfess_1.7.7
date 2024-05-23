

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


class ConfessionBox extends ConsumerWidget {
  final String message;
  final String username;
  final DateTime timeSent;
  final int likesCount;
  final int commentsCount;
  final Function() onTapLike;
  final Function() onTapComment;
  final Icon likeIconData;

  const ConfessionBox({
    Key? key,
    required this.message,
    required this.username,
    required this.timeSent,
    required this.likesCount,
    required this.commentsCount,
    required this.onTapLike,
    required this.likeIconData,
    required this.onTapComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = getUserScreenSize(context);
    return Container(
      decoration: ShapeDecoration(
          color: Colors.grey[900],
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40))),
      padding: const EdgeInsets.only(top: 16, bottom: 1, right: 16, left: 16),
      margin: const EdgeInsets.only(top: 4, bottom: 10, left: 10, right: 10),
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
                  '?$username?',
                  style: GoogleFonts.anonymousPro(
                    color: Colors.white54,
                    fontSize: 15,
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
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxFontSize: 14,
                  maxLines: 2,
                  minFontSize: 5,
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
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              // Use Lato font
            ),
            maxFontSize: 16,
            minFontSize: 12,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onTapLike,
                splashRadius: 10,
                icon: likeIconData,
              ),
              AutoSizeText(
                likesCount.toString(),
                style:
                    GoogleFonts.anonymousPro(color: whiteColor, fontSize: 16),
                maxFontSize: 20,
                minFontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                  onPressed: onTapComment,
                  splashRadius: 10,
                  icon: Icon(
                    Icons.comment,
                    color: Colors.grey.shade700,
                  )),
              AutoSizeText(
                commentsCount.toString(),
                style:
                    GoogleFonts.anonymousPro(color: whiteColor, fontSize: 16),
                maxFontSize: 20,
                minFontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }
}
