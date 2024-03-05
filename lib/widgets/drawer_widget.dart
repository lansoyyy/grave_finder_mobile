import 'package:flutter/material.dart';
import 'package:grave_finder/widgets/text_widget.dart';

import '../utlis/colors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                  text: 'John Doe',
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
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => const HomeScreen()));
              },
              title: TextWidget(
                text: 'Map',
                fontSize: 14,
                fontFamily: 'Bold',
              ),
            ),
            ListTile(
              onTap: () {
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => const HomeScreen()));
              },
              title: TextWidget(
                text: 'Navigation',
                fontSize: 14,
                fontFamily: 'Bold',
              ),
            ),
          ],
        ),
      )),
    );
  }
}
