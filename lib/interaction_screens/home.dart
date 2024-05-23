// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/interaction_screens/comments.dart';
import 'package:bitsconfess/models/post.dart';
import 'package:bitsconfess/widgets/confession_box.dart';

class HomeScreen extends ConsumerWidget {
  final String? currentUsername;
  const HomeScreen({
    super.key,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      "bits' confessions",
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
            Expanded(
              child: RefreshIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                onRefresh: () async {
                  await ref.read(authServiceProvider).fetchPosts(context);
                },
                child: StreamBuilder<List<Post>>(
                  stream: ref.watch(authServiceProvider).streamAllPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Loader());
                    }

                    final posts = snapshot.data;
                    if (posts == null || posts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No posts yet.',
                          style: TextStyle(color: whiteColor),
                        ),
                      );
                    }

                    final userState = ref.watch(authStreamProvider);
                    final userId = userState.maybeWhen(
                      data: (user) => user?.uid,
                      orElse: () => null,
                    );

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final isLiked =
                            userId != null && post.likes.contains(userId);
                        return ConfessionBox(
                          message: post.message,
                          username: post.username,
                          timeSent: post.timeSent,
                          likesCount: post.likes.length,
                          commentsCount: post.comments.length,
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddCommentsScreen(
                                      postId: post.postId,
                                      userId: user!.uid,
                                      username: post.username,
                                      currentUsername: currentUsername,
                                      message: post.message,
                                      timesent: post.timeSent,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
