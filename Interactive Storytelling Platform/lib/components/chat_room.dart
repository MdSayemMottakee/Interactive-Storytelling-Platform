import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomTitle;

  ChatRoomScreen({required this.roomId, required this.roomTitle});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String userId = 'user-id'; // Replace with the actual user ID
      String userName = 'User Name'; // Replace with the actual user name

      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('messages').add({
        'text': messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'senderId': userId,
        'senderName': userName,
      });
      
      // Clear the message input field after sending
      messageController.clear();

      // Scroll to the bottom of the list view to show the latest message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('messages').orderBy('createdAt').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];

                    return ListTile(
                      title: Text(message['senderName']),
                      subtitle: Text(message['text']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
