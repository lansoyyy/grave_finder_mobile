import 'package:flutter/material.dart';
import 'package:grave_finder/screens/home_screen.dart';
import 'package:grave_finder/screens/signup_page.dart';
import 'package:grave_finder/utlis/colors.dart';
import 'package:grave_finder/widgets/button_widget.dart';
import 'package:grave_finder/widgets/text_widget.dart';
import 'package:grave_finder/widgets/textfield_widget.dart';

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
              label: 'Username',
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldWidget(
              isObscure: true,
              controller: password,
              label: 'Password',
            ),
            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              label: 'Sign In',
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
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
}
