class LobbyChat {
  String username;
  String message;
  DateTime time;

  LobbyChat({
    required this.username,
    required this.message,
    required this.time,
  });

  factory LobbyChat.fromMap(Map<String, dynamic> map) {
    return LobbyChat(
      username: map['username'],
      message: map['message'],
      time: (map['time']).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'message': message,
      'time': time,
    };
  }
}

class RecentChat {
  final String uid; // User's UID
  final String username; // User's username
  final String lastMessage; // The last message in the chat

  RecentChat({required this.uid, required this.username, required this.lastMessage});
}

