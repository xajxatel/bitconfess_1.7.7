import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/interaction_screens/comments.dart';
import 'package:bitsconfess/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase_service/repo/auth.dart';
import '../widgets/trending_box.dart';

class TrendingScreen extends ConsumerWidget {
  final String? currentUsername;

  const TrendingScreen({
    Key? key,
    required this.currentUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = getUserScreenSize(context);
    return Scaffold(
      backgroundColor: blackColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 0,
                top: 20,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'spotlight',
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
            Center(
              child: StreamBuilder<Post?>(
                stream: ref
                    .read(authServiceProvider)
                    .getMostLikedConfessionForDay(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final mostLikedConfession = snapshot.data;
                    if (mostLikedConfession == null) {
                      return Column(
                        children: [
                          SizedBox(
                            height: size.height / 3,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'No confessions today',
                              style: GoogleFonts.anonymousPro(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      final userState = ref.watch(authStreamProvider);
                      final userId = userState.maybeWhen(
                        data: (user) => user?.uid,
                        orElse: () => null,
                      );

                      final isLiked = userId != null &&
                          mostLikedConfession.likes.contains(userId);

                      return TrendingBox(
                        message: mostLikedConfession.message,
                        username: mostLikedConfession.username,
                        timeSent: mostLikedConfession.timeSent,
                        likesCount: mostLikedConfession.likes.length,
                        commentsCount: mostLikedConfession.comments.length,
                        onTapLike: () {
                          if (isLiked) {
                            // Remove like
                            ref.read(authServiceProvider).removeLike(
                                  postId: mostLikedConfession.postId,
                                  userId: userId,
                                );
                          } else {
                            // Add like
                            ref.read(authServiceProvider).addLike(
                                  postId: mostLikedConfession.postId,
                                  userId: userId!,
                                );
                          }
                        },
                        likeIconData: Icon(
                          Icons.favorite,
                          color: isLiked ? primaryColor : Colors.grey,
                        ),
                        onTapComment: () async {
                          final user = await ref
                              .read(authServiceProvider)
                              .getCurrentUserData();
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddCommentsScreen(
                                    postId: mostLikedConfession.postId,
                                    userId: user!.uid,
                                    username: mostLikedConfession.username,
                                    currentUsername: currentUsername,
                                    message: mostLikedConfession.message,
                                    timesent: mostLikedConfession.timeSent,
                                  );
                                },
                              ),
                            );
                          }
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
