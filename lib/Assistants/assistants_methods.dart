import 'package:firebase_database/firebase_database.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/models/user_model.dart';

class AssistandMethods{
  static void readCurrentOnlineUserInfo() async{
    currentUser= firebaseAuth.currentUser;
    DatabaseReference userRef= FirebaseDatabase.instance
    .ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo= UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
}