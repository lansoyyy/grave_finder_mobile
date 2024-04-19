import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grave_finder/utlis/colors.dart';
import 'package:grave_finder/widgets/button_widget.dart';
import 'package:grave_finder/widgets/text_widget.dart';
import 'package:grave_finder/widgets/textfield_widget.dart';
import 'package:grave_finder/widgets/toast_widget.dart';
import 'package:intl/intl.dart';

Random random = Random();
int min = 100000; // 6-digit number range start
int max = 999999; // 6-digit number range end

class ReservationPage extends StatefulWidget {
  String username;
  String lotid;

  String id;

  ReservationPage(
      {super.key,
      required this.username,
      required this.lotid,
      required this.id});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final lname = TextEditingController();
  final fname = TextEditingController();

  final date = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(
      DateTime.now(),
    ),
  );

  final transactiono =
      TextEditingController(text: (min + random.nextInt(max - min)).toString());

  @override
  Widget build(BuildContext context) {
    final lotid = TextEditingController(text: widget.lotid);
    final username = TextEditingController(text: widget.username);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: TextWidget(
          text: 'Reservation',
          fontSize: 18,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFieldWidget(
                  isEnabled: false,
                  controller: transactiono,
                  label: 'Transaction No',
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  controller: fname,
                  label: 'Corpse First Name',
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  controller: lname,
                  label: 'Corpse Last Name',
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  isEnabled: false,
                  controller: lotid,
                  label: 'Lot ID',
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Date Reserved',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Bold',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Bold',
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          width: 325,
                          height: 50,
                          child: TextFormField(
                            enabled: false,
                            style: TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 14,
                              color: primary,
                            ),

                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                color: primary,
                              ),
                              hintStyle: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              hintText: date.text,
                              border: InputBorder.none,
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              errorStyle: const TextStyle(
                                  fontFamily: 'Bold', fontSize: 12),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            controller: date,
                            // Pass the validator to the TextFormField
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  isEnabled: false,
                  controller: username,
                  label: 'User',
                ),
                const SizedBox(
                  height: 30,
                ),
                ButtonWidget(
                  label: 'Submit',
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Slots')
                        .doc(widget.id)
                        .update({
                      'Name': '${fname.text} ${lname.text}',
                      'Status': 'Reserved',
                    }).whenComplete(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text:
                                            'Reservation Successful! Please proceed to the San Luis Memorial Park office (Lucban Academy, San Luis St., Barangay 8, Lucban, Quezon) Within 5-7 days for confirmation and approval of the reservation. If it expires, your reservation wil be removed from the list of pre-reserves.',
                                        fontSize: 13,
                                        fontFamily: 'Bold',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: ButtonWidget(
                                      radius: 20,
                                      height: 35,
                                      width: 75,
                                      fontSize: 12,
                                      label: 'Okay',
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dateFromPicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primary,
                onPrimary: Colors.white,
                onSurface: Colors.grey,
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2024));

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        date.text = formattedDate;
      });
    } else {
      return null;
    }
  }
}
