import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grave_finder/screens/home_screen.dart';
import 'package:grave_finder/screens/signup_page.dart';
import 'package:grave_finder/utlis/colors.dart';
import 'package:grave_finder/widgets/button_widget.dart';
import 'package:grave_finder/widgets/text_widget.dart';
import 'package:grave_finder/widgets/textfield_widget.dart';
import 'package:grave_finder/widgets/toast_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 250,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            TextFieldWidget(
              controller: username,
              label: 'Email',
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldWidget(
              isObscure: true,
              controller: password,
              label: 'Password',
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: ((context) {
                      final formKey = GlobalKey<FormState>();
                      final TextEditingController emailController =
                          TextEditingController();

                      return AlertDialog(
                        title: TextWidget(
                          text: 'Forgot Password',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        content: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFieldWidget(
                                hint: 'Email',
                                textCapitalization: TextCapitalization.none,
                                inputType: TextInputType.emailAddress,
                                label: 'Email',
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: (() {
                              Navigator.pop(context);
                            }),
                            child: TextWidget(
                              text: 'Cancel',
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: (() async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  Navigator.pop(context);
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: emailController.text);
                                  showToast(
                                      'Password reset link sent to ${emailController.text}');
                                } catch (e) {
                                  String errorMessage = '';

                                  if (e is FirebaseException) {
                                    switch (e.code) {
                                      case 'invalid-email':
                                        errorMessage =
                                            'The email address is invalid.';
                                        break;
                                      case 'user-not-found':
                                        errorMessage =
                                            'The user associated with the email address is not found.';
                                        break;
                                      default:
                                        errorMessage =
                                            'An error occurred while resetting the password.';
                                    }
                                  } else {
                                    errorMessage =
                                        'An error occurred while resetting the password.';
                                  }

                                  showToast(errorMessage);
                                  Navigator.pop(context);
                                }
                              }
                            }),
                            child: TextWidget(
                              text: 'Continue',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                },
                child: TextWidget(
                  text: 'Forgot Password?',
                  fontSize: 12,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              label: 'Sign In',
              onPressed: () async {
                // // Load the JSON file from assets
                // String jsonString =
                //     await rootBundle.loadString('assets/records.json');

                // // Parse the JSON string into a list of maps
                // List<dynamic> jsonData = jsonDecode(jsonString);

                // // Upload each map to Firestore
                // for (var data in jsonData) {
                //   await FirebaseFirestore.instance
                //       .collection('Slots')
                //       .add(data);
                // }
                login(context);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SignupPage()));
              },
              child: TextWidget(
                text: 'Create an account',
                fontSize: 14,
                color: primary,
                fontFamily: 'Bold',
              ),
            ),
          ],
        ),
      ),
    );
  }

  login(context) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.text, password: password.text);

      if (user.user!.emailVerified) {
        showToast('Logged in succesfully!');
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        showToast('Please verify your email!');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
