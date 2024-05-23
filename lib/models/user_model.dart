// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bitsconfess/models/post.dart';

class UserModel {
  String username;
  final String uid;
  final List<Post> posts;
  UserModel({
    required this.username,
    required this.uid,
    required this.posts,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uid': uid,
      'posts': posts.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      uid: map['uid'] as String,
      posts: List<Post>.from(
        (map['posts'] as List<dynamic>).map<Post>(
          (x) => Post.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
