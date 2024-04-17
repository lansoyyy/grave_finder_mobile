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
import 'package:grave_finder/utlis/distance_calculations.dart';
import 'package:grave_finder/utlis/get_location.dart';
import 'package:grave_finder/utlis/keys.dart';
import 'package:grave_finder/utlis/time_calculation.dart';
import 'package:grave_finder/widgets/drawer_widget.dart';
import 'package:grave_finder/widgets/toast_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/text_widget.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  bool hasLoaded = false;
  double lat = 0;
  double lng = 0;
  double selectedlat = 0;
  double selectedlng = 0;

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
      setState(() {
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

  bool started = false;

  bool navigated = false;

  String address = '';

  final map = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: navigated
          ? FloatingActionButton(
              child: const Icon(Icons.play_arrow),
              onPressed: () async {
                address = await getAddressFromLatLng(lat, lng);

                setState(() {
                  navigated = false;
                  started = true;
                });
              },
            )
          : const SizedBox(),
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: TextWidget(
          text: 'Navigation',
          fontSize: 18,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: hasLoaded
          ? StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Slots').snapshots(),
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
                      mapController: map,
                      options: MapOptions(
                        zoom: 18,
                        center: LatLng(14.110739, 121.550554),
                        minZoom: 1,
                        maxZoom: 100,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(
                          polylines: [poly],
                        ),
                        MarkerLayer(
                          markers: [
                            for (int i = 0; i < data.docs.length; i++)
                              Marker(
                                height: 8,
                                width: 8,
                                point: LatLng(
                                    double.parse(data.docs[i]['lat_long1']
                                        .toString()
                                        .split(', ')[0]),
                                    double.parse(data.docs[i]['lat_long1']
                                        .toString()
                                        .split(', ')[1])),
                                builder: (context) {
                                  return Transform.rotate(
                                    angle: 147 * 3.1415926535897932 / 190,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: TextWidget(
                                                text:
                                                    'Are you sure you want to go this grave?',
                                                fontSize: 18,
                                                fontFamily: 'Bold',
                                              ),
                                              content: data.docs[i]['Status'] ==
                                                          'Available' ||
                                                      data.docs[i]['Status'] ==
                                                          'Reserved'
                                                  ? const SizedBox()
                                                  : Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Name: ${data.docs[i]['Name']}',
                                                          fontSize: 18,
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Born: ${data.docs[i]['Born']}',
                                                          fontSize: 16,
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              'Died: ${data.docs[i]['Died']}',
                                                          fontSize: 16,
                                                        ),
                                                      ],
                                                    ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: TextWidget(
                                                    text: 'No',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    PolylineResult result =
                                                        await polylinePoints
                                                            .getRouteBetweenCoordinates(
                                                      kGoogleApiKey,
                                                      PointLatLng(lat, lng),
                                                      PointLatLng(
                                                          double.parse(data
                                                              .docs[i]
                                                                  ['lat_long1']
                                                              .toString()
                                                              .split(', ')[0]),
                                                          double.parse(data
                                                              .docs[i]
                                                                  ['lat_long1']
                                                              .toString()
                                                              .split(', ')[1])),
                                                    );
                                                    if (result
                                                        .points.isNotEmpty) {
                                                      polylineCoordinates = result
                                                          .points
                                                          .map((point) => LatLng(
                                                              point.latitude,
                                                              point.longitude))
                                                          .toList();
                                                    }

                                                    setState(() {
                                                      selectedlat =
                                                          double.parse(data
                                                              .docs[i]
                                                                  ['lat_long1']
                                                              .toString()
                                                              .split(', ')[0]);
                                                      selectedlng =
                                                          double.parse(data
                                                              .docs[i]
                                                                  ['lat_long1']
                                                              .toString()
                                                              .split(', ')[1]);
                                                      navigated = true;
                                                      poly = Polyline(
                                                        strokeWidth: 5,
                                                        points:
                                                            polylineCoordinates,
                                                        color: Colors.red,
                                                      );
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: TextWidget(
                                                    text: 'Yes',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: data.docs[i]['Status'] ==
                                                  'Available'
                                              ? Colors.green
                                              : data.docs[i]['Status'] ==
                                                      'Reserved'
                                                  ? Colors.amber
                                                  : Colors.red,
                                          border: Border.all(
                                              color: Colors.black, width: 0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                          ],
                        ),
                      ],
                    ),
                    !started
                        ? const SizedBox()
                        : Container(
                            width: double.infinity,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.u_turn_left,
                                    color: Colors.red,
                                    size: 75,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWidget(
                                        text:
                                            '${calculateDistance(lat, lng, selectedlat, selectedlng).toStringAsFixed(2)}km away',
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontFamily: 'Bold',
                                      ),
                                      TextWidget(
                                        text:
                                            '${calculateTravelTime(calculateDistance(lat, lng, selectedlat, selectedlng), 40).toStringAsFixed(2)} mins',
                                        fontSize: 24,
                                        color: Colors.grey,
                                        fontFamily: 'Bold',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    !started
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: TextWidget(
                                        text: address,
                                        fontSize: 18,
                                        fontFamily: 'Bold',
                                      ),
                                    ),
                                    Card(
                                      child: TextButton.icon(
                                        onPressed: () {
                                          map.move(LatLng(lat, lng), 18);
                                        },
                                        icon: const Icon(
                                          Icons.my_location,
                                          color: Colors.red,
                                        ),
                                        label: TextWidget(
                                          text: 'Center',
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                );
              })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  bool isPointInsidePolygon(LatLng tapPosition, List<LatLng> polygon) {
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
