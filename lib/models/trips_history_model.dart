import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? workerName;
  String? ratings;

  TripHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.car_details,
    this.workerName,
    this.ratings,
  });

  TripHistoryModel.fromSnapshot(DataSnapshot dataSnapshot){
    time= (dataSnapshot.value as Map)["time"];
    originAddress= (dataSnapshot.value as Map)["originAddress"];
    destinationAddress= (dataSnapshot.value as Map)["destinationAddress"];
    status= (dataSnapshot.value as Map)["status"];
    fareAmount= (dataSnapshot.value as Map)["fareAmount"];
    car_details= (dataSnapshot.value as Map)["car_details"];
    workerName= (dataSnapshot.value as Map)["workerName"];
    ratings= (dataSnapshot.value as Map)["ratings"];
  }
}