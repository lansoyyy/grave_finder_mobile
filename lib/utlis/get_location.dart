import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromLatLng(double lat, double lng) async {
  final currentAddress = await placemarkFromCoordinates(lat, lng);

  Placemark place = currentAddress[0];
  return place.name!;
}
