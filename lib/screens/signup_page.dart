import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grave_finder/screens/login_page.dart';
import 'package:grave_finder/services/signup.dart';
import 'package:grave_finder/utlis/colors.dart';
import 'package:grave_finder/widgets/button_widget.dart';
import 'package:grave_finder/widgets/text_widget.dart';
import 'package:grave_finder/widgets/textfield_widget.dart';
import 'package:grave_finder/widgets/toast_widget.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              TextWidget(
                text: 'User Registration',
                fontSize: 24,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                controller: firstname,
                label: 'First Name',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                controller: lastname,
                label: 'Last Name',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                controller: email,
                label: 'Email',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                controller: username,
                label: 'Username',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                showEye: true,
                isObscure: true,
                controller: password,
                label: 'Password',
              ),
              const SizedBox(
                height: 30,
              ),
              TextFieldWidget(
                showEye: true,
                isObscure: true,
                controller: confirmpassword,
                label: 'Confirm Password',
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                label: 'Sign Up',
                onPressed: () {
                  if (password.text != confirmpassword.text) {
                    showToast('Password do not match!');
                  } else {
                    register(context);
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonWidget(
                label: 'Back',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      // signup(nameController.text, numberController.text, addressController.text,
      //     emailController.text);

      signup(firstname.text, lastname.text, email.text, username.text);

      showToast("Registered Successfully!");

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
