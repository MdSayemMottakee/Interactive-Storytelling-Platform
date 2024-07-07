import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRoom extends StatelessWidget {
  final List<String> categories = [
    'Emotional Support',
    'Information Sharing',
    'Coping Strategies',
    'Social Connection',
    'Empowerment'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join a Room'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomsList(category: categories[index]),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoomsList extends StatelessWidget {
  final String category;

  RoomsList({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Room'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No rooms found for $category'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String roomId = document.id;
              String roomTitle = data['title'] ?? 'Unnamed Room';

              return ListTile(
                title: Text(roomTitle),
                subtitle: Text('Room ID: $roomId'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(roomId: roomId, roomTitle: roomTitle),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ChatRoomScreen extends StatelessWidget {
  final String roomId;
  final String roomTitle;

  ChatRoomScreen({required this.roomId, required this.roomTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomTitle),
      ),
      body: Center(
        child: Text(
          'Welcome to the $roomTitle!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: JoinRoom(),
  ));
}
