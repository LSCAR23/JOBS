import 'package:flutter/cupertino.dart';
import 'package:jobs/models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips=0;
  //List <String> historyTripsKeyList=[];
  //List<TripHistoryModel>allTripHistoryInformationList=[];

  void updatePickUpLocationAddress(Directions userPickUpddress){
    userPickUpLocation= userPickUpddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress){
    userDropOffLocation=userDropOffAddress;
    notifyListeners();
  }
}