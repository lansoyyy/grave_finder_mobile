import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grave_finder/screens/reservation_page.dart';
import 'package:grave_finder/utlis/keys.dart';
import 'package:grave_finder/widgets/button_widget.dart';
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
  bool hasLoaded = false;
  double lat = 0;
  double lng = 0;

  List<Polyline> polylines = const [];
  @override
  void initState() {
    determinePosition();

    getLocation();
    super.initState();
  }

  var poly = Polyline(points: [LatLng(0, 0)]);

  getLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((position) async {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(position.latitude, position.longitude),
        const PointLatLng(14.110409591799119, 121.55022553270486),
      );
      if (result.points.isNotEmpty) {
        polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }

      setState(() {
        poly = Polyline(
          isDotted: true,
          strokeWidth: 5,
          points: polylineCoordinates,
          color: Colors.red,
        );
        lat = position.latitude;
        lng = position.longitude;
        hasLoaded = true;
      });
    }).catchError((error) {
      print('Error getting location: $error');
    });
  }

  PolylinePoints polylinePoints = PolylinePoints();
  final searchController = TextEditingController();

  List<LatLng> polylineCoordinates = [];
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
            backgroundColor: const Color.fromARGB(255, 217, 219, 217),
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
            body: hasLoaded
                ? StreamBuilder<QuerySnapshot>(
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
                            color: Colors.white,
                          )),
                        );
                      }

                      final data = snapshot.requireData;

                      return Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              onTap: (tapPosition, point) {
                                print(point);
                                for (int i = 0; i < data.docs.length; i++) {
                                  final polygon = [
                                    LatLng(
                                        double.parse(data.docs[i]['lat_long1']
                                            .toString()
                                            .split(',')[0]),
                                        double.parse(data.docs[i]['lat_long1']
                                            .toString()
                                            .split(',')[1])),
                                    LatLng(
                                        double.parse(data.docs[i]['lat_long2']
                                            .toString()
                                            .split(',')[0]),
                                        double.parse(data.docs[i]['lat_long2']
                                            .toString()
                                            .split(',')[1])),
                                    LatLng(
                                        double.parse(data.docs[i]['lat_long3']
                                            .toString()
                                            .split(',')[0]),
                                        double.parse(data.docs[i]['lat_long3']
                                            .toString()
                                            .split(',')[1])),
                                    LatLng(
                                        double.parse(data.docs[i]['lat_long4']
                                            .toString()
                                            .split(',')[0]),
                                        double.parse(data.docs[i]['lat_long4']
                                            .toString()
                                            .split(',')[1]))
                                    // Add other points of the polygon similarly
                                  ];

                                  // Check if the tap position is within the polygon
                                  if (isPointInsidePolygon(point, polygon)) {
                                    // Show the index of the clicked polygon
                                    print('Clicked on polygon at index $i');

                                    if (data.docs[i]['Status'] != 'Reserved') {
                                      if (data.docs[i]['Status'] ==
                                          'Available') {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text: 'GRAVE INFORMATION',
                                                      fontSize: 18,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Block Name: ${data.docs[i]['block_name']}',
                                                          fontSize: 13,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Lot No.: ${data.docs[i]['lot_no']}',
                                                          fontSize: 13,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Lot Size: ${data.docs[i]['Lot Size']}',
                                                          fontSize: 13,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Lot per SQM: ${data.docs[i]['Price Per SQM']}',
                                                          fontSize: 13,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Lot Whole Price: ${data.docs[i]['Whole Price']}',
                                                          fontSize: 13,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Installment:  ',
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                            SizedBox(
                                                              width: 220,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  TextWidget(
                                                                    text: data
                                                                        .docs[i]
                                                                            [
                                                                            'Installment']
                                                                        .toString()
                                                                        .split(
                                                                            ', ')[0],
                                                                    fontSize:
                                                                        13,
                                                                    fontFamily:
                                                                        'Bold',
                                                                  ),
                                                                  TextWidget(
                                                                    text: data
                                                                        .docs[i]
                                                                            [
                                                                            'Installment']
                                                                        .toString()
                                                                        .split(
                                                                            ', ')[1],
                                                                    fontSize:
                                                                        13,
                                                                    fontFamily:
                                                                        'Bold',
                                                                  ),
                                                                  TextWidget(
                                                                    text: data
                                                                        .docs[i]
                                                                            [
                                                                            'Installment']
                                                                        .toString()
                                                                        .split(
                                                                            ', ')[2],
                                                                    fontSize:
                                                                        13,
                                                                    fontFamily:
                                                                        'Bold',
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        ButtonWidget(
                                                          color: Colors.white,
                                                          radius: 20,
                                                          height: 35,
                                                          width: 75,
                                                          textColor:
                                                              Colors.black,
                                                          fontSize: 12,
                                                          label: 'No',
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        ButtonWidget(
                                                          radius: 20,
                                                          height: 35,
                                                          width: 75,
                                                          fontSize: 12,
                                                          label: 'Reserve This',
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ReservationPage(
                                                                              id: data.docs[i].id,
                                                                              username: userdata['fname'],
                                                                              lotid: data.docs[i]['lot_no'].toString(),
                                                                            )));
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        showToast('Slot not available!');
                                      }
                                    } else {
                                      showToast('Slot is reserved!');
                                    }
                                    break; // Stop checking other polygons
                                  }
                                }
                              },
                              minZoom: 17.75,
                              maxZoom: 17.75,
                              zoom: 17.75,
                              center: LatLng(14.110724, 121.550274),
                            ),
                            children: [
                              // TileLayer(
                              //   errorImage: const AssetImage(
                              //     'assets/images/filled_map.png',
                              //   ),
                              //   urlTemplate:
                              //       'https://tile.openstreetmap.org1/{z}/{x}/{y}.png',
                              //   userAgentPackageName: 'com.example.app',
                              // ),

                              // OverlayImageLayer(
                              //   overlayImages: [
                              //     OverlayImage(
                              //       bounds: LatLngBounds(
                              //         LatLng(14.11226, 121.5461),
                              //         LatLng(14.10961, 121.55445),
                              //       ),
                              //       imageProvider: const AssetImage(
                              //         'assets/images/filled_map_label.png',
                              //       ),
                              //     ),
                              //   ],
                              // ),

                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 925,
                                    height: 925,
                                    point: LatLng(14.11100, 121.550180),
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          left: 32.5,
                                        ),
                                        child: Image.asset(
                                            'assets/images/filled_map_label.png'),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              PolygonLayer(
                                polygons: [
                                  for (int i = 0; i < data.docs.length; i++)
                                    Polygon(
                                        isFilled: true,
                                        color: data.docs[i]['Status'] ==
                                                'Available'
                                            ? Colors.green
                                            : data.docs[i]['Status'] ==
                                                    'Reserved'
                                                ? Colors.amber
                                                : Colors.red,
                                        points: [
                                          LatLng(
                                              double.parse(data.docs[i]
                                                      ['lat_long1']
                                                  .toString()
                                                  .split(',')[0]),
                                              double.parse(data.docs[i]
                                                      ['lat_long1']
                                                  .toString()
                                                  .split(',')[1])),
                                          LatLng(
                                              double.parse(data.docs[i]
                                                      ['lat_long2']
                                                  .toString()
                                                  .split(',')[0]),
                                              double.parse(data.docs[i]
                                                      ['lat_long2']
                                                  .toString()
                                                  .split(',')[1])),
                                          LatLng(
                                              double.parse(data.docs[i]
                                                      ['lat_long3']
                                                  .toString()
                                                  .split(',')[0]),
                                              double.parse(data.docs[i]
                                                      ['lat_long3']
                                                  .toString()
                                                  .split(',')[1])),
                                          LatLng(
                                              double.parse(data.docs[i]
                                                      ['lat_long4']
                                                  .toString()
                                                  .split(',')[0]),
                                              double.parse(data.docs[i]
                                                      ['lat_long4']
                                                  .toString()
                                                  .split(',')[1])),
                                        ])
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 75,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                          ),
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
                    })
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          );
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

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
