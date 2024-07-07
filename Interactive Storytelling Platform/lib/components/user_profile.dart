import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup/components/join_room.dart';
import 'package:login_signup/components/create_room.dart';
import 'package:login_signup/components/chat_page.dart'; // Import ChatPage
import 'package:login_signup/components/chat_room.dart'; // Import ChatPage
import 'package:login_signup/components/chatbot.dart'; // Import ChatPage

class UserProfile extends StatelessWidget {
  final String name;
  final String email;
  final String contact;
  final DateTime? birthday;
  final String country;
  final String gender;
  final String photoURL;

  const UserProfile({
    super.key,
    required this.name,
    required this.email,
    required this.contact,
    required this.birthday,
    required this.country,
    required this.gender,
    required this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    final cloudFunctionURL =
        'https://us-central1-your-project-id.cloudfunctions.net/getImage?imageUrl=${Uri.encodeComponent(photoURL)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Remove the current page from the navigation stack
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue,
                    Colors.deepPurple,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white, // Add a border or shadow if needed
                    backgroundImage: (photoURL.isNotEmpty
                        ? NetworkImage(cloudFunctionURL)
                        : const AssetImage(
                            'assets/images/default_avatar.png')
                            as ImageProvider),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to Home page
                Navigator.pop(context);
                // Implement navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat), // Icon for the chat
              title: const Text('Chat'), // Text label for the chat option
              onTap: () {
                Navigator.pop(context); // Close the drawer or navigate back if in a navigation stack
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(), // Navigate to the ChatPage widget
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.android), // Icon for the ChatGPT
              title: const Text('ChatGPT'), // Text label for the ChatGPT option
              onTap: () {
                Navigator.pop(context); // Close the drawer or navigate back if in a navigation stack
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatbotPage(), // Navigate to the ChatbotPage widget
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create Room'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRoom(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Join Room'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinRoom(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to Settings page
                Navigator.pop(context);
                // Implement navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                // Navigate to Help & Support page
                Navigator.pop(context);
                // Implement navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade200, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Name'),
                        subtitle: Text(name),
                        leading: const Icon(Icons.person),
                      ),
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(email),
                        leading: const Icon(Icons.email),
                      ),
                      ListTile(
                        title: const Text('Contact'),
                        subtitle: Text(contact),
                        leading: const Icon(Icons.phone),
                      ),
                      ListTile(
                        title: const Text('Birthday'),
                        subtitle: Text(
                            birthday != null ? DateFormat('yyyy-MM-dd').format(birthday!) : ''),
                        leading: const Icon(Icons.cake),
                      ),
                      ListTile(
                        title: const Text('Country'),
                        subtitle: Text(country),
                        leading: const Icon(Icons.location_on),
                      ),
                      ListTile(
                        title: const Text('Gender'),
                        subtitle: Text(gender),
                        leading: const Icon(Icons.face),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement update profile functionality here
                  // Example: Navigate to edit profile page
                  Navigator.pushNamed(context, '/edit_profile');
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
