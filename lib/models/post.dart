class Post {
  String postId; // Unique ID for each post
  String userId; // ID of the user who created the post
  String username; // Username of the user who created the post
  String message; // The content/message of the post
  DateTime timeSent; // The timestamp when the post was created
  List<String> likes; // List of user IDs who liked the post
  List<Comment> comments; // List of comments on the post

  // Constructor
  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.message,
    required this.timeSent,
    required this.likes,
    required this.comments,
  });

  // Factory method to create a Post object from a map
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'],
      userId: map['userId'],
      username: map['username'],
      message: map['message'],
      timeSent: map['timeSent'].toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<Comment>.from(
        (map['comments'] as List<dynamic>? ?? []).map(
          (commentMap) => Comment.fromMap(commentMap),
        ),
      ),
    );
  }

  // Method to convert a Post object to a map
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'message': message,
      'timeSent': timeSent,
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }
  
}

class Comment {
  String userId; // ID of the user who posted the comment
  String username; // Username of the user who posted the comment
  String text; // The content/text of the comment
  DateTime timeSent; // The timestamp when the comment was posted

  Comment({
    required this.userId,
    required this.username,
    required this.text,
    required this.timeSent,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'],
      username: map['username'],
      text: map['text'],
      timeSent: map['timeSent'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'text': text,
      'timeSent': timeSent,
    };
  }
}
