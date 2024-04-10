import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grave_finder/screens/login_page.dart';
import 'package:grave_finder/screens/route_page.dart';
import 'package:grave_finder/widgets/text_widget.dart';

import '../screens/home_screen.dart';
import '../utlis/colors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
        stream: userData,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          dynamic data = snapshot.data;
          return Container(
            height: double.infinity,
            width: 250,
            color: background,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: primary),
                            shape: BoxShape.circle,
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: Image.asset(
                            'assets/images/profile.png',
                            height: 35,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      TextWidget(
                        text: data['fname'] + ' ' + data['lname'],
                        fontFamily: 'Bold',
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    },
                    title: TextWidget(
                      text: 'Map',
                      fontSize: 14,
                      fontFamily: 'Bold',
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const RouteScreen()));
                    },
                    title: TextWidget(
                      text: 'Navigation',
                      fontSize: 14,
                      fontFamily: 'Bold',
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                  'Logout Confirmation',
                                  style: TextStyle(
                                      fontFamily: 'QBold',
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to Logout?',
                                  style: TextStyle(fontFamily: 'QRegular'),
                                ),
                                actions: <Widget>[
                                  MaterialButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()));
                                    },
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ));
                    },
                    title: TextWidget(
                      text: 'Logout',
                      fontSize: 14,
                      fontFamily: 'Bold',
                    ),
                  ),
                ],
              ),
            )),
          );
        });
  }
}
