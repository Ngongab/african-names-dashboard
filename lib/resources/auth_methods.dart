import 'dart:typed_data';

import 'package:admin/models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        //register user
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        var uid = userCred.user!.uid;

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //add user to database

        model.User user = model.User(
          username: username,
          uid: uid,
          email: email,
          bio: bio,
          photoUrl: photoUrl,
        );
        await _firestore.collection('users').doc(uid).set(
              user.toJson(),
            );
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print(res);
        res = 'success';
        print(res);
      } else {
        print(res);
        res = 'Please enter all fields';
      }
    } catch (err) {
      print(res);
      res = err.toString();
    }
    print(res);
    return res;
  }
}
