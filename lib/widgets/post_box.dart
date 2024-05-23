// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:bitsconfess/helpers/utils.dart';

class PostBox extends ConsumerWidget {
  final String message;

  final DateTime timeSent;
  final int likesCount;
  final int commentsCount;
  final Function() onTapLike;
  final Function() onTapComment;
  final Function() onTapDelete;
  final Icon likeIconData;

  const PostBox({
    Key? key,
    required this.message,
    required this.timeSent,
    required this.likesCount,
    required this.commentsCount,
    required this.onTapLike,
    required this.onTapComment,
    required this.onTapDelete,
    required this.likeIconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = getUserScreenSize(context);
    return Container(
      decoration: ShapeDecoration(
          color: Colors.grey[900],
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40))),
      padding: const EdgeInsets.only(top: 7, bottom: 1, right: 16, left: 16),
      margin: const EdgeInsets.only(top: 1, bottom: 10, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            overflow: TextOverflow.clip,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: size.width / 10,
                child: AutoSizeText(
                  formatRelativeTime(timeSent.toLocal()),
                  style: GoogleFonts.anonymousPro(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxFontSize: 14,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onTapLike,
                splashRadius: 10,
                icon: likeIconData,
              ),
              AutoSizeText(
                likesCount.toString(),
                style:
                    GoogleFonts.anonymousPro(color: whiteColor, fontSize: 16),
                maxFontSize: 16,
                minFontSize: 10,
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
                maxFontSize: 16,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                  onPressed: onTapDelete,
                  splashRadius: 10,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade800,
                    size: 25,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
