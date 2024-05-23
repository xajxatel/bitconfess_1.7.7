import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/models/post.dart';
import 'package:bitsconfess/widgets/comment_box.dart';
import 'package:bitsconfess/widgets/post_heading.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  final String userId;
  final String username;
  final String? currentUsername;
  final String message;
  final DateTime timesent;

  const AddCommentsScreen({
    Key? key,
    required this.postId,
    required this.message,
    required this.userId,
    required this.username,
    required this.currentUsername,
    required this.timesent,
  }) : super(key: key);

  @override
  ConsumerState<AddCommentsScreen> createState() => _AddCommentsScreenState();
}

class _AddCommentsScreenState extends ConsumerState<AddCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final comments =
        await ref.read(authServiceProvider).getComments(widget.postId);
    setState(() {
      _comments = comments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        title: AutoSizeText(
          'Comments',
          style: GoogleFonts.anonymousPro(fontSize: 23.5),
          maxFontSize: 24,
          minFontSize: 15,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          PostHeadingWidget(
            message: widget.message,
            username: widget.username,
            timeSent: widget.timesent,
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CommentBox(
                      commentText: comment.text,
                      commenterName: comment.username,
                      timeSent: comment.timeSent),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900], // Set background color
                borderRadius: BorderRadius.circular(20.0), // Set rounded border
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 1,
                      maxLength: 1000,

                      cursorColor: Colors.white, // Set cursor color to white
                      style: GoogleFonts.anonymousPro(
                          color: Colors.white), // Set text color to white
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                            color: Colors.grey), // Set hint text color
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // Remove border line
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0), // Adjust padding
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white, // Set icon color to white
                    ),
                    onPressed: () {
                      final commentText = _commentController.text.trim();
                      if (commentText.isNotEmpty) {
                        ref.read(authServiceProvider).addComment(
                              postId: widget.postId,
                              userId: widget.userId,
                              username: widget.currentUsername!,
                              commentText: commentText,
                            );
                        _commentController.clear();
                        _fetchComments(); // Fetch comments again after adding a new comment
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
