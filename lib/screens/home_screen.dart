import 'package:flutter/material.dart';
import 'package:grave_finder/widgets/drawer_widget.dart';
import 'package:photo_view/photo_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: PhotoView(
          imageProvider: const AssetImage(
              'assets/images/CementeryMap-SanLuisMemorialPark.png'),
        ));
  }
}
