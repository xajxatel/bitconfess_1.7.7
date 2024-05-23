import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/models/user_model.dart';
import 'package:bitsconfess/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> signInAnon() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text;
    bool containsSpace = username.contains(' ');
    const pattern = r'^[a-z0-9_]+$';
    final regExp = RegExp(pattern);
    bool checkUsername = regExp.hasMatch(username);

    if (username.trim().isNotEmpty && !containsSpace && checkUsername) {
      List<UserModel> allUsers =
          await ref.read(authServiceProvider).getAllUsers(context);
      bool usernameExists = allUsers.any((user) => user.username == username);

      if (usernameExists) {
        if (context.mounted) {
          showSnackBar(context: context, content: "Username already taken.");
        }
      } else {
        if (context.mounted) {
          await ref.watch(authServiceProvider).signInAnonymously(context);
        }

        if (context.mounted) {
          ref.read(authServiceProvider).saveUserDataToFirebase(
                context: context,
                username: username,
              );
        }
      }
    } else {
      // Show an error message or snackbar if the username field is empty
      showSnackBar(
          context: context,
          content: "underscores, numbers and lowercaseses only");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = getUserScreenSize(context);
    return Scaffold(
      backgroundColor: blackColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height / 2,
              width: size.width,
              child: Image.asset(
                'assets/username.png',
                color: primaryColor,
              ),
            ),
            AutoSizeText(
              'Select an Alias',
              style:
                  GoogleFonts.anonymousPro(color: Colors.white, fontSize: 25),
              maxFontSize: 25,
              minFontSize: 15,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: size.width / 1.7,
              height: 80,
              child: TextField(
                controller: _usernameController,
                textAlign: TextAlign.center,
                cursorColor: whiteColor,
                maxLength: 20,
                maxLines: 1,
                style:
                    GoogleFonts.lato(color: Colors.grey.shade500, fontSize: 23),
                decoration:  InputDecoration(
                  counterText: "",
                  hintText: 'username',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 21),
                  contentPadding: EdgeInsets.all(20),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: whiteColor)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _isLoading
                ? const Loader() // Show circular progress indicator while loading
                : CustomButton(
                    buttonWidth: 0.4,
                    onTap: () {
                      signInAnon();
                    },
                    text: "Create",
                    color: primaryColor,
                  ),
          ],
        ),
      ),
    );
  }
}
