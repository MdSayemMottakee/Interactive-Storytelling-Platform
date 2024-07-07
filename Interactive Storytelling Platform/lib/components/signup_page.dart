import 'dart:typed_data';
import 'dart:io'; // Add this import for File class
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/components/login_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:login_signup/components/common/page_header.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Uint8List? _profileImageBytes;
  File? _profileImageFile; // Change to nullable
  final _signupFormKey = GlobalKey<FormState>();
  DateTime? _selectedBirthday;
  String? _selectedGender;
  String? _selectedCountry;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

// Function to convert Uint8List to File
Future<File> _convertBytesToFile(Uint8List bytes) async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/profile_image.jpg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  } catch (e) {
    throw Exception('Error converting bytes to File: $e');
  }
}


  Future<void> _pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        if (kIsWeb) {
          _profileImageBytes = result.files.single.bytes;
        } else {
          _profileImageFile = File(result.files.single.path!);
        }
        setState(() {}); // Update the UI to show selected image
      } else {
        // User canceled the picker
      }
    } catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }


Future<void> _handleSignupUser() async {
  if (_signupFormKey.currentState!.validate()) {
    print('Form validation passed.');

    // Check if profile image is selected
    if (_profileImageFile == null && _profileImageBytes == null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Please select a profile image.')),
      );
      return;
    }

    _scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Submitting data..')),
    );

    try {
      String? profileImageUrl;

      // Upload profile image if available
      if (_profileImageFile != null) {
        profileImageUrl = await uploadProfileImageFile(_profileImageFile!);
      } else if (_profileImageBytes != null) {
        profileImageUrl = await uploadProfileImageBytes(_profileImageBytes!);
      }

      // Check if the widget is still mounted before accessing context
      if (!mounted) {
        return;
      }
      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password' :_passwordController.text.trim(),
        'contact': _contactController.text.trim(),
        'birthday': _selectedBirthday != null
            ? DateFormat('yyyy-MM-dd').format(_selectedBirthday!)
            : '',
        'country': _selectedCountry ?? '',
        'gender': _selectedGender ?? '',
        'photoURL': profileImageUrl ?? '',

      });
      // Navigate to the login page after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Error handling
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    }
  } 
}



  Future<String> uploadProfileImageBytes(Uint8List imageBytes) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      UploadTask uploadTask = storageReference.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

Future<String> uploadProfileImageFile(File imageFile) async {
  try {
    String fileName = imageFile.path.split('/').last; // For Unix-like paths
    // String fileName = imageFile.path.split('\\').last; // For Windows paths
    Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$fileName');

    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    debugPrint('Error uploading image: $e');
    throw Exception('Failed to upload image');
  }
}



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldMessengerKey,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 210, 151, 234),
                Color.fromARGB(255, 155, 45, 198),
                Color.fromARGB(255, 74, 0, 129),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _signupFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PageHeader(),
                  // Header widgets
                  const SizedBox(height: 16),
                  const PageHeading(title: 'Sign Up',),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor:
                              const Color.fromARGB(158, 146, 144, 149),
                          backgroundImage: _profileImageBytes != null
                              ? MemoryImage(_profileImageBytes!)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.camera_alt_sharp,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact',
                        hintText: 'Enter your contact number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        hint: const Text('Select Gender'),
                        items: ['Male', 'Female', 'Other']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none, // Remove the underline
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'Birthday',
                        hintText: _selectedBirthday != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedBirthday!)
                            : 'Select your birthday',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        hint: const Text('Select Country'),
                        items: ['Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia',
                                'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin',
                                'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi',
                                'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia',
                                'Comoros', 'Congo, Democratic Republic of the', 'Congo, Republic of the', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus',
                                'Czech Republic', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'East Timor', 'Ecuador', 'Egypt',
                                'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France',
                                'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana',
                                'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Italy',
                                'Ivory Coast', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Korea, North', 'Korea, South', 'Kosovo',
                                'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania',
                                'Luxembourg', 'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania',
                                'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar',
                                'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Macedonia', 'Norway',
                                'Oman', 'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland',
                                'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines',
                                'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore',
                                'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname',
                                'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Togo', 'Tonga', 'Trinidad and Tobago',
                                'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
                                'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none, // Remove the underline
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _handleSignupUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
