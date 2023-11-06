import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore db= FirebaseFirestore.instance;

Future<void> save_user(var user) async{
  await db.collection("users").add(user).catchError((errorMessage) {
          Fluttertoast.showToast(msg: 'Error occured: \n $errorMessage');
        });;
}
