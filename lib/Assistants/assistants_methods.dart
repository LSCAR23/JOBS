import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jobs/Assistants/request_assistant.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/global/map_key.dart';
import 'package:jobs/models/directions.dart';
import 'package:jobs/models/user_model.dart';

class AssistandMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
        String apiUrl= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
        String humanReadableAddress="";
        var requestResponse= await RequestAssistant.receiveRequest(apiUrl);
        if(requestResponse!= "Error Occured. Failed. No response."){
          humanReadableAddress= requestResponse["results"][0]["formatted_address"];

          Directions userPickUpAddress= Directions();
          userPickUpAddress.locationLatitude= position.latitude;
          userPickUpAddress.locationLongitude= position.longitude;
          userPickUpAddress.locationName= humanReadableAddress;

          //Provider.of<AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);
        }
        return humanReadableAddress;
      }
}
