import 'dart:async';

import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/models/chat.dart';
import 'package:bitsconfess/models/post.dart';
import 'package:bitsconfess/models/user_model.dart';
import 'package:bitsconfess/interaction_screens/nav_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final authServiceProvider = Provider((ref) => AuthService(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

final authStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserCurrentState();
});

final userDataAuthProvider = FutureProvider((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.getCurrentUserData();
});

final totalUserCountProvider = FutureProvider<int>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getTotalUserCount();
});

final totalUserCountStreamProvider = StreamProvider<int>((ref) {
  final firestore = FirebaseFirestore.instance;

  // Create a reference to the 'users' collection
  final usersCollection = firestore.collection('users');

  // Create a stream that listens for changes to the collection
  final userCountStream = usersCollection.snapshots().map((querySnapshot) {
    return querySnapshot.size;
  });

  return userCountStream;
});

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthService({
    required this.auth,
    required this.firestore,
  });

  Future signInAnonymously(BuildContext context) async {
    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    final userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();

    UserModel? user;

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }

    return user;
  }

  Future<List<UserModel>> getAllUsers(BuildContext context) async {
    try {
      QuerySnapshot usersSnapshot = await firestore.collection('users').get();
      return usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  Stream<User?> getUserCurrentState() {
    return auth.authStateChanges();
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required String username,
  }) async {
    try {
      String uid = auth.currentUser!.uid;

      UserModel user = UserModel(username: username, uid: uid, posts: []);

      await firestore.collection('users').doc(uid).set(user.toMap());

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NavScreen(
                username: user.username,
                currentUserId: user.uid,
              ),
            ),
            (route) => false);
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  // Function to get user data from Firebase
  Future<UserModel> getUserData(String uid, BuildContext context) async {
    try {
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      return UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  Future<void> saveUserPost(
      {required String message, required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      UserModel? user = await getUserData(uid, context);
      // Create a new postId using Uuid()
      String postId = const Uuid().v1();

      // Create a Post object with the given message
      Post post = Post(
        likes: [],
        comments: [],
        message: message,
        userId: uid,
        postId: postId,
        timeSent: DateTime.now(),
        username: user.username,
      );

      // Save the Post to the "posts" collection under the document named postId
      await firestore.collection('posts').doc(postId).set(post.toMap());

      // Get the current UserModel

      // Add the new Post to the user's list of posts
      user.posts.add(post);

      // Save the updated UserModel back to Firebase under the document named uid
      await firestore.collection('users').doc(uid).set(user.toMap());
      if (context.mounted) {
        showSnackBar(context: context, content: 'Posted');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  // Function to get all posts from Firebase
  Future<List<Post>> getAllPosts(BuildContext context) async {
    try {
      QuerySnapshot postSnapshot = await firestore.collection('posts').get();
      return postSnapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  Stream<List<Post>> streamAllPosts() {
    return firestore
        .collection('posts')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => Post.fromMap(doc.data())).toList());
  }

  Future<void> addLike({required String postId, required String userId}) async {
    try {
      await firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeLike(
      {required String postId, required String userId}) async {
    try {
      await firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      // Handle error
    }
  }

// Function to add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    required String commentText,
  }) async {
    try {
      Comment comment = Comment(
        userId: userId,
        username: username,
        text: commentText,
        timeSent: DateTime.now(),
      );

      await firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await firestore.collection('posts').doc(postId).get();

      if (postSnapshot.exists) {
        var postData = postSnapshot.data() as Map<String, dynamic>;
        List<dynamic> commentData = postData['comments'];
        return commentData
            .map((commentMap) => Comment.fromMap(commentMap))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // Handle error
      return [];
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      String uid = auth.currentUser!.uid;

      // Traverse all posts in the "posts" collection
      QuerySnapshot postSnapshot = await firestore.collection('posts').get();
      for (DocumentSnapshot doc in postSnapshot.docs) {
        // Remove comments made by the user on this post
        List<dynamic> commentsData = doc['comments'];
        List<Map<String, dynamic>> updatedComments = [];
        for (var commentMap in commentsData) {
          Comment comment = Comment.fromMap(commentMap);
          if (comment.userId != uid) {
            updatedComments.add(comment.toMap());
          }
        }
        doc.reference.update({'comments': updatedComments});
      }

      // Delete the user data from the "users" collection
      await firestore.collection('users').doc(uid).delete();

      // Delete the user account
      await auth.currentUser!.delete();
      if (context.mounted) {
        showSnackBar(context: context, content: 'Account deleted successfully');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Post>> getUserPosts(String userId, BuildContext context) async {
    try {
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        // Explicitly cast the data to Map<String, dynamic>
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        // Get the user's posts field (assuming it's a List<dynamic>)
        List<dynamic> userPostsData = userData?['posts'] ?? [];
        // Convert the data to List<Post>
        List<Post> userPosts = userPostsData.map((postData) {
          return Post.fromMap(postData as Map<String, dynamic>);
        }).toList();

        return userPosts;
      } else {
        return [];
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  Future<void> deletePost(String postId, BuildContext context) async {
    try {
      await firestore.collection('posts').doc(postId).delete();

      // Get the current user's UID
      String uid = auth.currentUser!.uid;

      // Fetch the user's data from Firestore
      final userDataSnapshot =
          await firestore.collection('users').doc(uid).get();
      final userData =
          UserModel.fromMap(userDataSnapshot.data() as Map<String, dynamic>);

      // Remove the deleted post from the user's posts list
      userData.posts.removeWhere((post) => post.postId == postId);

      // Update the user's data in Firestore
      await firestore.collection('users').doc(uid).set(userData.toMap());
      if (context.mounted) {
        showSnackBar(context: context, content: 'Post deleted successfully');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Post>> fetchPosts(BuildContext context) async {
    try {
      QuerySnapshot postSnapshot = await firestore.collection('posts').get();
      return postSnapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      rethrow;
    }
  }

  Future<int> getTotalUserCount() async {
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    return usersSnapshot.size;
  }

  Stream<Post?> getMostLikedConfessionForDay(BuildContext context) {
    final currentDate = DateTime.now();

    return firestore
        .collection('posts')
        .where('timeSent',
            isGreaterThanOrEqualTo:
                DateTime(currentDate.year, currentDate.month, currentDate.day))
        .snapshots()
        .map((querySnapshot) {
      final posts =
          querySnapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();

      if (posts.isEmpty) {
        return null;
      }

      posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
      return posts.first;
    });
  }

  Stream<bool> checkAndEnforcePostLimit() async* {
    final prefs = await SharedPreferences.getInstance();
    final postLimit = prefs.getInt('postLimit') ?? 3; // Default limit is 3

    while (true) {
      final userPostCount = prefs.getInt('userPostCount') ?? 0;
      final now = DateTime.now();
      final endOfDayTimestamp = prefs.getInt('endOfDayTimestamp') ?? 0;
      final endOfDay = DateTime.fromMillisecondsSinceEpoch(endOfDayTimestamp);

      if (now.isAfter(endOfDay)) {
        // Reset the limit if it's a new day
        await prefs.setInt('postLimit', 3); // Change 3 to your desired limit
        await prefs.setInt('endOfDayTimestamp',
            endOfDay.add(Duration(days: 1)).millisecondsSinceEpoch);
      }

      yield userPostCount >= postLimit;
      await Future.delayed(Duration(minutes: 1)); // Adjust the delay as needed
    }
  }

  Stream<QuerySnapshot> getChatMessagesStream() {
    // Reference to the "chats" collection in Firestore, ordered by timestamp
    final chatCollection = firestore.collection('chats').orderBy('time');

    // Return a stream that listens for changes in the chat collection
    return chatCollection.snapshots();
  }

  void addChatMessage(String message, String username) async {
    final user = auth.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final chatMessage = LobbyChat(
      username: username,
      message: message,
      time: DateTime.now(),
    );

    await firestore.collection('chats').add(chatMessage.toMap());
  }

  String currentSearchQuery = '';
  void setSearchQuery(String query) {
    currentSearchQuery = query;
  }

  // Function to search for users
}
