import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_room.dart'; // Import the ChatRoomScreen

class CreateRoom extends StatefulWidget {
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final List<String> categories = [
    'Emotional Support',
    'Information Sharing',
    'Coping Strategies',
    'Social Connection',
    'Empowerment'
  ];
  
  String? selectedCategory;
  TextEditingController roomTitleController = TextEditingController();

  void createRoom() async {
    if (selectedCategory != null && roomTitleController.text.isNotEmpty) {
      // Create room data
      String userId = 'user-id';  // Replace with the actual user ID
      Map<String, dynamic> roomData = {
        'category': selectedCategory,
        'title': roomTitleController.text,
        'owner': userId, // Record owner ID
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Upload to Firestore
      DocumentReference roomRef = await FirebaseFirestore.instance.collection('rooms').add(roomData);

      // Add room to user's chat list
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('chats').add({
        'roomId': roomRef.id,
        'roomTitle': roomTitleController.text,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Navigate to the created chat room
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(roomId: roomRef.id, roomTitle: roomTitleController.text),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category and enter a room title')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              value: selectedCategory,
            ),
            SizedBox(height: 20),
            TextField(
              controller: roomTitleController,
              decoration: InputDecoration(
                labelText: 'Room Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createRoom,
              child: Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}
