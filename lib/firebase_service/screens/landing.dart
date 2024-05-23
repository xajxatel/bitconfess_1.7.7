import 'package:bitsconfess/firebase_service/screens/sign_in.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void goTosignInScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SignInScreen();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = getUserScreenSize(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: blackColor,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child:
                      Image.asset('assets/username.png', color: primaryColor),),
              Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'bits confess',
                          curve: Curves.easeInOut,
                          textStyle: GoogleFonts.anonymousPro(
                              color: Colors.white70,
                              fontSize: size.width / 10,
                              fontWeight: FontWeight.w500),
                          speed: const Duration(milliseconds: 200),
                        ),
                      ],
                      repeatForever: true,
                      isRepeatingAnimation: true,
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                  )),
              SizedBox(
                height: size.height / 4.5,
              ),
              CustomButton(
                color: primaryColor,
                buttonWidth: 0.6,
                text: 'Join anonymously',
                onTap: () => goTosignInScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
