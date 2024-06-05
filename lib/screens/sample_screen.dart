import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        zoom: 18,
        center: LatLng(14.110739, 121.550554),
        minZoom: 1,
        maxZoom: 18,
      ),
      children: [
        OverlayImageLayer(
          overlayImages: [
            OverlayImage(
              // Unrotated
              bounds: LatLngBounds(
                LatLng(14.11226, 121.5461),
                LatLng(14.10961, 121.55445),
              ),
              imageProvider: const AssetImage(
                'assets/images/map.jpg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
