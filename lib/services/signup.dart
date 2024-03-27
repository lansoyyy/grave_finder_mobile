import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future signup(fname, lname, email, username) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'fname': fname,
    'username': username,
    'lname': lname,
    'email': email,
    'id': docUser.id,
  };

  await docUser.set(json);
}
