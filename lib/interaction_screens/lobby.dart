import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/helpers/utils.dart';
import 'package:bitsconfess/models/chat.dart';
import 'package:bitsconfess/widgets/sender_chat.dart';
import 'package:bitsconfess/widgets/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String? currentUsername;
  const LobbyScreen({
    super.key,
    required this.currentUsername,
  });

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 30000);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<LobbyChat> getChatMessagesFromSnapshot(QuerySnapshot snapshot) {
    final messages = <LobbyChat>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final message = LobbyChat.fromMap(data);
      messages.add(message);
    }
    return messages;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(microseconds: 1),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final authService = ref.read(authServiceProvider);
      authService.addChatMessage(
        messageText,
        widget.currentUsername!,
      );
      _messageController.clear();

      // Scroll to the bottom after sending a message
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'lobby',
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.read(authServiceProvider).getChatMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Loader(),
                  );
                }

                final messages = getChatMessagesFromSnapshot(snapshot.data!);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Start a conversation',
                      style: GoogleFonts.anonymousPro(
                          color: primaryColor, fontSize: 24),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return message.username == widget.currentUsername
                        ? UserChat(message: message)
                        : SenderChat(message: message);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLength: 1000,
                    cursorColor: primaryColor,
                    style: GoogleFonts.anonymousPro(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.anonymousPro(
                        color: Colors.grey,
                      ),
                      fillColor: blackColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
