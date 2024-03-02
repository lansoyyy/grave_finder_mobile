import 'package:flutter/material.dart';
import 'package:grave_finder/screens/login_page.dart';
import 'package:grave_finder/utlis/colors.dart';
import 'package:grave_finder/widgets/button_widget.dart';
import 'package:grave_finder/widgets/text_widget.dart';
import 'package:grave_finder/widgets/textfield_widget.dart';

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
                isObscure: true,
                controller: password,
                label: 'Password',
              ),
              const SizedBox(
                height: 30,
              ),
              TextFieldWidget(
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
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginPage()));
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
}
