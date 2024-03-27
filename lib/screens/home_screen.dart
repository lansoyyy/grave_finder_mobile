import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grave_finder/widgets/drawer_widget.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String nameSearched = '';
  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  @override
  Widget build(BuildContext context) {
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
          return Scaffold(
              drawer: const DrawerWidget(),
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                title: TextWidget(
                  text: '${'Welcome, ' + data['fname']} ',
                  fontSize: 18,
                  fontFamily: 'Bold',
                ),
              ),
              body: Stack(
                children: [
                  PhotoView(
                    imageProvider: const AssetImage(
                        'assets/images/CementeryMap-SanLuisMemorialPark.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 40,
                            width: 350,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(100)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Regular',
                                    fontSize: 14),
                                onChanged: (value) {
                                  setState(() {
                                    nameSearched = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                      fontFamily: 'QRegular',
                                      color: Colors.white,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    )),
                                controller: searchController,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget(
                          text: 'Legend',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 75,
                                  color: Colors.green,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextWidget(
                                  text: 'Available',
                                  fontSize: 12,
                                  fontFamily: 'Bold',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 75,
                                  color: Colors.yellow,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextWidget(
                                  text: 'Pre-Reserved',
                                  fontSize: 12,
                                  fontFamily: 'Bold',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 75,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextWidget(
                                  text: 'Occupied',
                                  fontSize: 12,
                                  fontFamily: 'Bold',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }
}
