import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:grave_finder/screens/reservation_page.dart';
import 'package:grave_finder/widgets/drawer_widget.dart';
import 'package:grave_finder/widgets/toast_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:latlong2/latlong.dart';
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
          dynamic userdata = snapshot.data;
          return Scaffold(
              drawer: const DrawerWidget(),
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                title: TextWidget(
                  text: '${'Welcome, ' + userdata['fname']} ',
                  fontSize: 18,
                  fontFamily: 'Bold',
                ),
              ),
              body: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Slots')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print('error');
                      return const Center(child: Text('Error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        )),
                      );
                    }

                    final data = snapshot.requireData;

                    return Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            onTap: (tapPosition, points) {
                              for (int i = 0; i < data.docs.length; i++) {
                                final polygon = [
                                  LatLng(
                                      double.parse(data.docs[i]['lat_long1']
                                          .toString()
                                          .split(', ')[0]),
                                      double.parse(data.docs[i]['lat_long1']
                                          .toString()
                                          .split(', ')[1])),
                                  LatLng(
                                      double.parse(data.docs[i]['lat_long2']
                                          .toString()
                                          .split(', ')[0]),
                                      double.parse(data.docs[i]['lat_long2']
                                          .toString()
                                          .split(', ')[1])),
                                  LatLng(
                                      double.parse(data.docs[i]['lat_long3']
                                          .toString()
                                          .split(', ')[0]),
                                      double.parse(data.docs[i]['lat_long3']
                                          .toString()
                                          .split(', ')[1])),
                                  LatLng(
                                      double.parse(data.docs[i]['lat_long4']
                                          .toString()
                                          .split(', ')[0]),
                                      double.parse(data.docs[i]['lat_long4']
                                          .toString()
                                          .split(', ')[1]))
                                  // Add other points of the polygon similarly
                                ];

                                // Check if the tap position is within the polygon
                                if (isPointInsidePolygon(points, polygon)) {
                                  // Show the index of the clicked polygon
                                  print('Clicked on polygon at index $i');
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ReservationPage(
                                            username: userdata['fname'],
                                            lotid: data.docs[i]['lot_no']
                                                .toString(),
                                          )));
                                  break; // Stop checking other polygons
                                } else {
                                  showToast('Slot not available!');
                                }
                              }
                            },
                            minZoom: 1,
                            maxZoom: 100,
                            initialCenter: const LatLng(14.110707, 121.550554),
                            initialZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            PolygonLayer(polygons: [
                              for (int i = 0; i < data.docs.length; i++)
                                Polygon(
                                    isFilled: true,
                                    color: data.docs[i]['Name'] == 'Available'
                                        ? Colors.green
                                        : Colors.red,
                                    points: [
                                      LatLng(
                                          double.parse(data.docs[i]['lat_long1']
                                              .toString()
                                              .split(', ')[0]),
                                          double.parse(data.docs[i]['lat_long1']
                                              .toString()
                                              .split(', ')[1])),
                                      LatLng(
                                          double.parse(data.docs[i]['lat_long2']
                                              .toString()
                                              .split(', ')[0]),
                                          double.parse(data.docs[i]['lat_long2']
                                              .toString()
                                              .split(', ')[1])),
                                      LatLng(
                                          double.parse(data.docs[i]['lat_long3']
                                              .toString()
                                              .split(', ')[0]),
                                          double.parse(data.docs[i]['lat_long3']
                                              .toString()
                                              .split(', ')[1])),
                                      LatLng(
                                          double.parse(data.docs[i]['lat_long4']
                                              .toString()
                                              .split(', ')[0]),
                                          double.parse(data.docs[i]['lat_long4']
                                              .toString()
                                              .split(', ')[1]))
                                    ])
                            ])
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              // Align(
                              //   alignment: Alignment.topCenter,
                              //   child: Container(
                              //     height: 40,
                              //     width: 350,
                              //     decoration: BoxDecoration(
                              //         border: Border.all(
                              //           color: Colors.white,
                              //         ),
                              //         borderRadius: BorderRadius.circular(100)),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(
                              //           left: 10, right: 10),
                              //       child: TextFormField(
                              //         style: const TextStyle(
                              //             color: Colors.white,
                              //             fontFamily: 'Regular',
                              //             fontSize: 14),
                              //         onChanged: (value) {
                              //           setState(() {
                              //             nameSearched = value;
                              //           });
                              //         },
                              //         decoration: const InputDecoration(
                              //             labelStyle: TextStyle(
                              //               color: Colors.white,
                              //             ),
                              //             hintText: 'Search',
                              //             hintStyle: TextStyle(
                              //               fontFamily: 'QRegular',
                              //               color: Colors.white,
                              //             ),
                              //             prefixIcon: Icon(
                              //               Icons.search,
                              //               color: Colors.white,
                              //             )),
                              //         controller: searchController,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextWidget(
                                text: 'Legend',
                                fontSize: 18,
                                fontFamily: 'Bold',
                                color: Colors.black,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }));
        });
  }

  bool isPointInsidePolygon(LatLng tapPosition, List<LatLng> polygon) {
    bool isInside = false;
    double minX = polygon[0].latitude;
    double maxX = polygon[0].latitude;
    double minY = polygon[0].longitude;
    double maxY = polygon[0].longitude;
    for (int i = 1; i < polygon.length; i++) {
      LatLng vertex = polygon[i];
      minX = minX < vertex.latitude ? minX : vertex.latitude;
      maxX = maxX > vertex.latitude ? maxX : vertex.latitude;
      minY = minY < vertex.longitude ? minY : vertex.longitude;
      maxY = maxY > vertex.longitude ? maxY : vertex.longitude;
    }

    if (tapPosition.latitude < minX ||
        tapPosition.latitude > maxX ||
        tapPosition.longitude < minY ||
        tapPosition.longitude > maxY) {
      return false;
    }

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].longitude > tapPosition.longitude) !=
              (polygon[j].longitude > tapPosition.longitude) &&
          tapPosition.latitude <
              (polygon[j].latitude - polygon[i].latitude) *
                      (tapPosition.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) +
                  polygon[i].latitude) {
        inside = !inside;
      }
    }
    return inside;
  }
}
