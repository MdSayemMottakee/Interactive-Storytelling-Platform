import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:firebase_auth/firebase_auth.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, 'login_signup/components/login_page', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: $name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: $email'),
            const SizedBox(height: 8),
            Text('Contact: $contact'),
            const SizedBox(height: 8),
            Text('Birthday: ${birthday != null ? DateFormat('yyyy-MM-dd').format(birthday!) : ''}'),
            const SizedBox(height: 8),
            Text('Country: $country'),
            const SizedBox(height: 8),
            Text('Gender: $gender'),
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
    );
  }
}
