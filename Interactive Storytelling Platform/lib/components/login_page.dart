import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/components/common/custom_input_field.dart';
import 'package:login_signup/components/common/page_header.dart';
import 'package:login_signup/components/forget_password_page.dart';
import 'package:login_signup/components/signup_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/components/common/custom_form_button.dart';
import 'package:login_signup/components/user_profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffEEF1F3),
          body: Column(
            children: [
              const PageHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          const PageHeading(title: 'Log-in',),
                          CustomInputField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Your email id',
                            validator: (textValue) {
                              if(textValue == null || textValue.isEmpty) {
                                return 'Email is required!';
                              }
                              if(!EmailValidator.validate(textValue)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            }
                          ),
                          const SizedBox(height: 16,),
                          CustomInputField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Your password',
                            obscureText: true,
                            suffixIcon: true, 
                            validator: (textValue) {
                              if(textValue == null || textValue.isEmpty) {
                                return 'Password is required!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,),
                          Container(
                            width: size.width * 0.80,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage()))
                              },
                              child: const Text(
                                'Forget password?',
                                style: TextStyle(
                                  color: Color(0xff939393),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          CustomFormButton(innerText: 'Login', onPressed: _handleLoginUser,),
                          const SizedBox(height: 18,),
                          SizedBox(
                            width: size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Don\'t have an account ? ', style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()))
                                  },
                                  child: const Text('Sign-up', style: TextStyle(fontSize: 15, color: Color(0xff748288), fontWeight: FontWeight.bold),),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

Future<void> _handleLoginUser() async {
  if (_loginFormKey.currentState!.validate()) {
    // Trimmed email and password from the controllers
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting data..')),
    );

    if (!EmailValidator.validate(email)) {
      print('Invalid email format');
      return;
    }

    try {
      // Query Firestore based on email and password
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // User found, you can access user data
        for (var doc in snapshot.docs) {
          print('User data: ${doc.data()}');
        }

        // Fetch user data from Firestore based on the authenticated user's email
        QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        // Example of extracting specific fields if needed
        String name = userData.docs.first['name'];
        String contact = userData.docs.first['contact'];
        DateTime? birthday = userData.docs.first['birthday'] != null
            ? DateTime.parse(userData.docs.first['birthday'])
            : null;
        String country = userData.docs.first['country'];
        String gender = userData.docs.first['gender'];
        String photoURL = userData.docs.first['photoURL'];

        // Navigate to user profile page or perform other actions
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(
              email: email,
              name: name,
              contact: contact,
              birthday: birthday,
              country: country,
              gender: gender,
              photoURL: photoURL,
            ),
          ),
        );
      } else {
        // Handle case where no user data is found
        print('User not found for email: $email');
        // Display appropriate message or handle error
      }
    } catch (e) {
      print('Login failed: $e');
      // Display specific error messages based on the type of exception
      // Handle different Firebase Authentication error codes if needed
      print('Unknown error occurred: $e');
    }
  }
}
}
