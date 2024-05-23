// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';

import 'package:bitsconfess/interaction_screens/trending.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/interaction_screens/confessions.dart';
import 'package:bitsconfess/interaction_screens/home.dart';
import 'package:bitsconfess/interaction_screens/profile.dart';
import 'package:bitsconfess/interaction_screens/settings.dart';

class NavScreen extends StatefulWidget {
  final String? username;
  final String? currentUserId;
  const NavScreen({
    Key? key,
    required this.username,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadColor();
  }

  void setIndex(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(selectedIndex);
    });
  }

  Future<void> loadColor() async {
    final savedColor = await getPrimaryColor();
    setState(() {
      primaryColor = savedColor;
    });
  }

  void changeAppColor() async {
    final newColor = cyclePrimaryColor(primaryColor);
    setState(() {
      primaryColor = newColor;
    });

    // Save the selected color using the utility function
    await setPrimaryColor(newColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            setState(() {
              changeAppColor();
            });
          },
          child: AutoSizeText(
            'Confess',
            style: GoogleFonts.montez(color: primaryColor, fontSize: 45),
            maxFontSize: 45,
            minFontSize: 15,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        controller: _pageController,
        children: [
          HomeScreen(currentUsername: widget.username),
          ConfessionsScreen(username: widget.username),
          TrendingScreen(currentUsername: widget.username),
          // LobbyScreen(currentUsername: widget.username),
          ProfileScreen(username: widget.username),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: blackColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          child: GNav(
              color: whiteColor,
              tabBackgroundColor: Colors.grey.shade900,
              activeColor: Colors.grey.shade900,
              gap: 10,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
              selectedIndex: selectedIndex,
              tabs: [
                GButton(
                  onPressed: () => setIndex(0),
                  iconActiveColor: whiteColor,
                  activeBorder: Border.all(color: primaryColor, width: 2),
                  textStyle:
                      GoogleFonts.anonymousPro(fontSize: 18, color: whiteColor),
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  onPressed: () => setIndex(1),
                  iconActiveColor: whiteColor,
                  activeBorder: Border.all(color: primaryColor, width: 2),
                  textStyle:
                      GoogleFonts.anonymousPro(fontSize: 18, color: whiteColor),
                  icon: Icons.edit,
                  text: 'Confess',
                ),
                GButton(
                  onPressed: () => setIndex(2),
                  iconActiveColor: whiteColor,
                  activeBorder: Border.all(color: primaryColor, width: 2),
                  textStyle:
                      GoogleFonts.anonymousPro(fontSize: 18, color: whiteColor),
                  icon: Icons.favorite,
                  text: 'Spotlight',
                ),
                // GButton(
                //   onPressed: () => setIndex(3),
                //   iconActiveColor: whiteColor,
                //   activeBorder: Border.all(color: Colors.purple, width: 2),
                //   textStyle:
                //       GoogleFonts.anonymousPro(fontSize: 13, color: whiteColor),
                //   icon: Icons.smoking_rooms,
                //   text: 'Lobby',
                // ),
                GButton(
                  onPressed: () => setIndex(3),
                  iconActiveColor: whiteColor,
                  activeBorder: Border.all(color: primaryColor, width: 2),
                  textStyle:
                      GoogleFonts.anonymousPro(fontSize: 18, color: whiteColor),
                  icon: Icons.person,
                  text: 'Profile',
                ),
                GButton(
                  onPressed: () => setIndex(4),
                  iconActiveColor: whiteColor,
                  activeBorder: Border.all(color: primaryColor, width: 2),
                  textStyle:
                      GoogleFonts.anonymousPro(fontSize: 18, color: whiteColor),
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ]),
        ),
      ),
    );
  }
}
