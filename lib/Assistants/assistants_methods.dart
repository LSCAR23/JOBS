import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobs/Assistants/request_assistant.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/global/map_key.dart';
import 'package:jobs/infoHandler/app_info.dart';
import 'package:jobs/models/direction_details_info.dart';
import 'package:jobs/models/directions.dart';
import 'package:jobs/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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

          Provider.of<AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);
        }
        return humanReadableAddress;
      }
  
  static Future <DirectionsDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
   String urlOriginToDestinationDirectionDetails= "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
  var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

  DirectionsDetailsInfo directionsDetailsInfo= DirectionsDetailsInfo();
  directionsDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

  directionsDetailsInfo.distance_text= responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
  directionsDetailsInfo.distance_value= responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
  directionsDetailsInfo.duration_text= responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
  directionsDetailsInfo.duration_value= responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

  return directionsDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionsDetailsInfo directionsDetailsInfo){
    double timeTraveledFareAmountPerMinute = (directionsDetailsInfo.duration_value!/60) * 0.1;
    double distanceTraveledFareAmountPerKilometer= (directionsDetailsInfo.duration_value!/1000)*0.1;

    double totalFareAmount= timeTraveledFareAmountPerMinute+ distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));

  }

  static sendNotificationToWorkerNow(String deviceRegistrationToken, String userRideRequestId, context) async{
    String destinationAddress= userDropOffAddress;

    Map <String, String> headerNotification={
      'Content-Type':'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification={
      "body": "Destination Address: \n$destinationAddress",
      "title":"New Trip Request"
    };

    Map dataMap={
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id":"1",
      "status":"done",
      "rideRequestId":userRideRequestId
    };

    Map officialNotificationFormat={
      "notification": bodyNotification,
      "data":dataMap,
      "priority":"high",
      "to":deviceRegistrationToken,
    };

    var responseNotification= http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat)
      );

  }

}
