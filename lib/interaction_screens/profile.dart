// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/interaction_screens/comments.dart';
import 'package:bitsconfess/models/post.dart';
import 'package:bitsconfess/widgets/post_box.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  final String? username;

  const ProfileScreen({
    super.key,
    required this.username,
  });

  void _confirmDeleteConfession(
      BuildContext context, WidgetRef ref, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Delete confession?',
            style: GoogleFonts.anonymousPro(color: whiteColor),
          ),
          content: Text(
              'Are you sure you want to delete your confesssion? This action cannot be undone.',
              style: GoogleFonts.anonymousPro(color: Colors.grey.shade400)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text(
                'Cancel',
                style:
                    GoogleFonts.anonymousPro(color: Colors.white, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(authServiceProvider).deletePost(
                      postId,
                      context,
                    );
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style:
                    GoogleFonts.anonymousPro(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStreamProvider);
    final userId = userState.maybeWhen(
      data: (user) => user?.uid,
      orElse: () => null,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'my confessions',
                      curve: Curves.ease,
                      textStyle: GoogleFonts.anonymousPro(
                          color: Colors.grey.shade500,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
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
            Flexible(
              flex: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 15, bottom: 20),
                margin: const EdgeInsets.only(bottom: 10),
                height: 60,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AutoSizeText(
                    username!,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.anonymousPro(
                        color: primaryColor, fontSize: 27),
                    maxFontSize: 30,
                    minFontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: ref.watch(authServiceProvider).streamAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Loader(),
                    );
                  }

                  final posts = snapshot.data;
                  if (posts == null || posts.isEmpty) {
                    return const Center(
                      child: AutoSizeText(
                        'No posts yet.',
                        style: TextStyle(color: whiteColor),
                        maxFontSize: 25,
                        minFontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }

                  final userPosts =
                      posts.where((post) => post.userId == userId).toList();

                  if (userPosts.isEmpty) {
                    return Center(
                      child: Text(
                        'no confessions yet',
                        style: GoogleFonts.anonymousPro(
                            color: whiteColor, fontSize: 20),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      final post = userPosts[index];
                      final isLiked =
                          userId != null && post.likes.contains(userId);
                      return PostBox(
                        message: post.message,
                        timeSent: post.timeSent,
                        likesCount: post.likes.length,
                        commentsCount: post.comments.length,
                        onTapDelete: () {
                          // Call deletePost function here
                          _confirmDeleteConfession(context, ref, post.postId);
                        },
                        onTapLike: () {
                          if (userId != null) {
                            if (isLiked) {
                              // Remove like
                              ref.read(authServiceProvider).removeLike(
                                    postId: post.postId,
                                    userId: userId,
                                  );
                            } else {
                              // Add like
                              ref.read(authServiceProvider).addLike(
                                    postId: post.postId,
                                    userId: userId,
                                  );
                            }
                          }
                        },
                        likeIconData: Icon(
                          Icons.favorite,
                          color: isLiked ? primaryColor : Colors.grey,
                        ),
                        onTapComment: () async {
                          final user = await ref
                              .watch(authServiceProvider)
                              .getCurrentUserData();
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return AddCommentsScreen(
                                  postId: post.postId,
                                  userId: user!.uid,
                                  username: user.username,
                                  message: post.message,
                                  timesent: post.timeSent,
                                  currentUsername: username,
                                );
                              },
                            ));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
