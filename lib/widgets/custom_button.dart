import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bitsconfess/helpers/utils.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final Color color;
  final double buttonWidth;

  const CustomButton({
    Key? key,
    required this.onTap,
    required this.text,
    required this.color,
    required this.buttonWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = constraints.maxWidth * buttonWidth;

        return InkWell(
            onTap: onTap,
            child: Container(
              decoration: ShapeDecoration(
                  color: color,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(13))),
              alignment: Alignment.center,
              width: buttonSize,
              height: 50,
              child: Center(
                child: AutoSizeText(
                  '?  $text  ?',
                  style: GoogleFonts.anonymousPro(
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  maxFontSize: 16,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ));
      },
    );
  }
}
