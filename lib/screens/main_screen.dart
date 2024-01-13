import 'dart:async';
//import 'dart:html';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jobs/Assistants/assistants_methods.dart';
import 'package:jobs/Assistants/geofire_assistant.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/global/map_key.dart';
import 'package:jobs/infoHandler/app_info.dart';
import 'package:jobs/models/active_nearby_available_workers.dart';
import 'package:jobs/models/direction_details_info.dart';
import 'package:jobs/models/directions.dart';
import 'package:jobs/screens/drawer_screen.dart';
import 'package:jobs/screens/precise_pickup_location.dart';
import 'package:jobs/screens/search_places_screen.dart';
import 'package:jobs/splash_screen/splash_screen.dart';
import 'package:jobs/widgets/pay_fare_amount_dialog.dart';
import 'package:jobs/widgets/progress_dialog.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromWorkerContainerHeight = 0;
  double assignedWorkerInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForWorkerContainerHeight=0;

  Position? userCurrentPosition;

  var geoLocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingofMap = 0;

  List<LatLng> pLineCoordidatedList = [];

  Set<Polyline> polylineSet = {};
  Set<Circle> circlesSet = {};
  Set<Marker> markersSet = {};
  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;

  bool activeNearbyWorkersKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String selectedVehicleType = "";

  String workerRequestStatus="Worker is coming";

  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  List <ActiveNearbyAvailableWorkers> onlineNearbyAvailableWorkersList=[];

  String userRideRequestStatus= "";

  bool requestPositionInfo= true;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssistandMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    print("This is our address = " + humanReadableAddress);
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initilizeGeoFireListener();
    //AssistandMethods.readTripsKeyForOnineUser(context);
  }

  initilizeGeoFireListener() {
    Geofire.initialize("activeWorkers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableWorkers activeNearbyAvailableWorkers =
                ActiveNearbyAvailableWorkers();
            activeNearbyAvailableWorkers.locationLatitude = map["latitude"];
            activeNearbyAvailableWorkers.locationLongitude = map["longitude"];
            activeNearbyAvailableWorkers.workerId = map["key"];
            GeoFireAssistant.activeNearbyAvailableWorkersList
                .add(activeNearbyAvailableWorkers);
            if (activeNearbyWorkersKeysLoaded == true) {
              displayActiveworkersOnUsersMap();
            }
            break;
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineWorkersFromList(map["key"]);
            displayActiveworkersOnUsersMap();
            break;
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableWorkers activeNearbyAvailableWorkers =
                ActiveNearbyAvailableWorkers();
            activeNearbyAvailableWorkers.locationLatitude = map["latitude"];
            activeNearbyAvailableWorkers.locationLongitude = map["longitude"];
            activeNearbyAvailableWorkers.workerId = map["key"];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableWorkers);
            displayActiveworkersOnUsersMap();
            break;
          case Geofire.onGeoQueryReady:
            activeNearbyWorkersKeysLoaded = true;
            displayActiveworkersOnUsersMap();
            break;
        }
      }
      setState(() {});
    });
  }

  displayActiveworkersOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> workersMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableWorkers eachWorker
          in GeoFireAssistant.activeNearbyAvailableWorkersList) {
        LatLng eachWorkerActivePosition =
            LatLng(eachWorker.locationLatitude!, eachWorker.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachWorker.workerId!),
          position: eachWorkerActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        workersMarkerSet.add(marker);

        setState(() {
          markersSet = workersMarkerSet;
        });
      }
    });
  }

  createActiveNearbyWorkerIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/worker.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait",
      ),
    );
    var directionsDetailsInfo =
        await AssistandMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    setState(() {
      tripDirectionsDetailsInfo = directionsDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionsDetailsInfo.e_points!);
    pLineCoordidatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordidatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordidatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker origenMarker = Marker(
      markerId: MarkerId("origenID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(origenMarker);
      markersSet.add(destinationMarker);
    });

    Circle origenCircle = Circle(
      circleId: CircleId("origenID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(origenCircle);
      circlesSet.add(destinationCircle);
    });
  }

  showSearchingForWorkersContainer(){
    setState(() {
      searchingForWorkerContainerHeight=200;
    });
  }

  showSuggestedRidesContainer() {
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingofMap = 400;
    });
  }

  /*getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapKey);
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);

        //_address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }*/

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveRequestInformation(String selectedVehicleType){
    referenceRideRequest= FirebaseDatabase.instance.ref().child("All rides Requests").push();

    var originLocation= Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationLocation= Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    Map originLocationMap={
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap={
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap={
      "origin": originLocationMap,
      "destination":destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress":originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "workerId": "waiting",
    };
    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription= referenceRideRequest!.onValue.listen((eventSnap) async{
      if(eventSnap.snapshot.value==null){
        return;
      }
      if((eventSnap.snapshot.value as Map)["car_details"]!= null){
        setState(() {
          workerCarDetails= (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["workerPhone"]!= null){
        setState(() {
          workerCarDetails= (eventSnap.snapshot.value as Map)["workerPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["workerName"]!= null){
        setState(() {
          workerCarDetails= (eventSnap.snapshot.value as Map)["workerName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"]!= null){
        setState(() {
          userRideRequestStatus= (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["workerLocation"]!= null){
        double workerCurrentPositionLat= double.parse((eventSnap.snapshot.value as Map)["workerLocation"]["latitude"].toString());
        double workerCurrentPositionLng= double.parse((eventSnap.snapshot.value as Map)["workerLocation"]["longitude"].toString());

        LatLng workerCurrentPositionLatLng= LatLng(workerCurrentPositionLat, workerCurrentPositionLng);

        if(userRideRequestStatus=="accepted"){
          updateArrivalTimeToUserPicUpLocation(workerCurrentPositionLatLng);
        }

        if(userRideRequestStatus=="arrived"){
          setState(() {
            workerRequestStatus="Worker has arrived";
          });
        }

        if(userRideRequestStatus== "ontrip"){
          updateReachingTimeToUserDropOffLocation(workerCurrentPositionLatLng);
        }

        if(userRideRequestStatus=="ended"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context, 
              builder: (BuildContext context)=> PayFareAmountDialog(
                fareAmount:fareAmount
              )
            );

            if(response=="Cash Paid"){
              if((eventSnap.snapshot.value as Map)["workerId"] != null){
                String assignedWorkerId= (eventSnap.snapshot.value as Map)["workerId"].toString();
                //Navigator.push(context, MaterialPageRoute(builder: (c)=> RateWorkerScreen()));

                referenceRideRequest!.onDisconnect();
                tripRidesRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
     });

     onlineNearbyAvailableWorkersList= GeoFireAssistant.activeNearbyAvailableWorkersList;
     searchNearstOnlineWorkers(selectedVehicleType);
  }

  searchNearstOnlineWorkers(String selectedVehicleType)async{
    if(onlineNearbyAvailableWorkersList.length==0){
      referenceRideRequest!.remove();
      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoordidatedList.clear();
      });

      Fluttertoast.showToast(msg: "No online nearest Worker available");
      Fluttertoast.showToast(msg: "Search Again. \n Restarting App");

      Future.delayed(Duration(milliseconds: 4000),(){
        referenceRideRequest!.remove();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> SplashScreen()));
      });

      return;
    }

    await retrieveOnlineWorkersInformation(onlineNearbyAvailableWorkersList);

    print("Worker List: "+ workersList.toString());

    for (var i = 0; i < workersList.length; i++) {
      if(workersList[i]["car_details"]["type"]== selectedVehicleType){
        AssistandMethods.sendNotificationToWorkerNow(workersList[i]["token"], referenceRideRequest!.key!,context);
      }
      
    }
    Fluttertoast.showToast(msg: "Notification Sent Succesfully");
    showSearchingForWorkersContainer();

    await  FirebaseDatabase.instance.ref().child("All Ride Request").child(referenceRideRequest!.key!).child("workerId").onValue.listen((eventRideRequestSnapshot) {
      print ("EvenSnapshot:${eventRideRequestSnapshot.snapshot.value}");
      if(eventRideRequestSnapshot.snapshot.value!=null){
        if(eventRideRequestSnapshot.snapshot.value!="waiting"){
          showUIForAssignedWorkerInfo();
        }
      }
    });
  }

  

  updateArrivalTimeToUserPicUpLocation(workerCurrentPositionLatLng) async{
    if(requestPositionInfo==true){
      requestPositionInfo= false;
      LatLng userPickUpLocation = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo= await AssistandMethods.obtainOriginToDestinationDirectionDetails(workerCurrentPositionLatLng, userPickUpLocation);

      if(directionDetailsInfo==null){
        return;
      }

      setState(() {
        workerRequestStatus= "Worker is coming: "+ directionDetailsInfo.duration_text.toString();

      });

      requestPositionInfo= true;
    }

    
  }

  updateReachingTimeToUserDropOffLocation(workerCurrentPositionLatLng) async {
    if(requestPositionInfo==true){
      requestPositionInfo= false;
       var dropOffLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

       LatLng userDestinationPosition= LatLng(
        dropOffLocation!.locationLatitude!, 
        dropOffLocation.locationLongitude!,
        );

        var directionDetailsInfo= await AssistandMethods.obtainOriginToDestinationDirectionDetails(
          workerCurrentPositionLatLng, 
          userDestinationPosition
          );

        if(directionDetailsInfo== null){
          return;
        }
        setState(() {
          workerRequestStatus= "Going towards destination: "+ directionDetailsInfo.duration_text.toString();
        });

        requestPositionInfo=true;
    }
  }

  showUIForAssignedWorkerInfo(){
    setState(() {
      waitingResponsefromWorkerContainerHeight=0;
      searchLocationContainerHeight=0;
      assignedWorkerInfoContainerHeight=200;
      suggestedRidesContainerHeight=0;
      bottomPaddingofMap=200;
    });
  }

  retrieveOnlineWorkersInformation(List onlineNearesWorkersList) async{
    workersList.clear();
    DatabaseReference ref= FirebaseDatabase.instance.ref().child("workers");

    for (var i = 0; i < onlineNearesWorkersList.length; i++) {
      await ref.child(onlineNearesWorkersList[i].workerId.toString()).once().then((dataSnapshot){
        var workerKeyInfo= dataSnapshot.snapshot.value;

        workersList.add(workerKeyInfo);
        print("Worker Key Information = "+ workersList.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    //bool darkTheme = true;
    createActiveNearbyWorkerIconMarker();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 40, bottom: (bottomPaddingofMap)),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  bottomPaddingofMap = 200;
                });
                locateUserPosition();
              },
              /*onCameraMove: (CameraPosition? position) {
                if (pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                getAddressFromLatLng();
              },*/
            ),
            /*
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset(
                  "images/pointer.png",
                  height: 45,
                  width: 45,
                ),
              ),
            ),*/

            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: darkTheme ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: darkTheme
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("From",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.amber.shade400
                                                  : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        Text(
                                          Provider.of<AppInfo>(context)
                                                      .userPickUpLocation !=
                                                  null
                                              ? (Provider.of<AppInfo>(context)
                                                          .userPickUpLocation!
                                                          .locationName!)
                                                      .substring(0, 24) +
                                                  "..."
                                              : "Not Getting Address",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(
                                height: 1,
                                thickness: 2,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () async {
                                    var responseFromSearchScreen =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) =>
                                                    SearchPlacesScreen()));

                                    if (responseFromSearchScreen ==
                                        "obtainedDropoff") {
                                      setState(() {
                                        openNavigationDrawer = false;
                                      });
                                    }

                                    await drawPolyLineFromOriginToDestination(
                                        darkTheme);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("To",
                                              style: TextStyle(
                                                color: darkTheme
                                                    ? Colors.amber.shade400
                                                    : Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .userDropOffLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userDropOffLocation!
                                                    .locationName!
                                                : "Where to",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => PrecisePickUpScreen()));
                              },
                              child: Text(
                                "Change Pick Up Address",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (Provider.of<AppInfo>(context, listen: false)
                                        .userDropOffLocation !=
                                    null) {
                                  showSuggestedRidesContainer();
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please select a destination location");
                                }
                              },
                              child: Text(
                                "Show Fare",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )),
                            )
                          ],
                        )
                      ]),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestedRidesContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                                Provider.of<AppInfo>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? (Provider.of<AppInfo>(context)
                                                .userPickUpLocation!
                                                .locationName!)
                                            .substring(0, 24) +
                                        "..."
                                    : "Not Getting Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                                Provider.of<AppInfo>(context)
                                            .userDropOffLocation !=
                                        null
                                    ? Provider.of<AppInfo>(context)
                                        .userDropOffLocation!
                                        .locationName!
                                    : "Where to",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "SUGGESTED RIDES",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVehicleType = "Car";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedVehicleType == "Car"
                                            ? Colors.blue
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(25.0),
                                        child: Column(
                                          children: [
                                            Image.asset("images/worker.png",
                                                scale: 1),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "Car",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedVehicleType == "Car"
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              tripDirectionsDetailsInfo != null
                                                  ? "₡${((AssistandMethods.calculateFareAmountFromOriginToDestination(tripDirectionsDetailsInfo!) * 2) * 550).toStringAsFixed(1)}"
                                                  : "null",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVehicleType = "CNG";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedVehicleType == "CNG"
                                            ? Colors.blue
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(25.0),
                                        child: Column(
                                          children: [
                                            Image.asset("images/worker.png",
                                                scale: 1),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "CNG",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedVehicleType == "CNG"
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              tripDirectionsDetailsInfo != null
                                                  ? "₡${((AssistandMethods.calculateFareAmountFromOriginToDestination(tripDirectionsDetailsInfo!) * 1.5) * 550).toStringAsFixed(1)}"
                                                  : "null",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVehicleType = "Bike";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedVehicleType == "Bike"
                                            ? Colors.blue
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(25.0),
                                        child: Column(
                                          children: [
                                            Image.asset("images/worker.png",
                                                scale: 1),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "Bike",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedVehicleType == "Bike"
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              tripDirectionsDetailsInfo != null
                                                  ? "₡${((AssistandMethods.calculateFareAmountFromOriginToDestination(tripDirectionsDetailsInfo!) * 1) * 550).toStringAsFixed(1)}"
                                                  : "null",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVehicleType = "Bike";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedVehicleType == "Bike"
                                            ? Colors.blue
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(25.0),
                                        child: Column(
                                          children: [
                                            Image.asset("images/worker.png",
                                                scale: 1),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "Bike",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedVehicleType == "Bike"
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              tripDirectionsDetailsInfo != null
                                                  ? "₡${((AssistandMethods.calculateFareAmountFromOriginToDestination(tripDirectionsDetailsInfo!) * 1) * 550).toStringAsFixed(1)}"
                                                  : "null",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  
                                ])),

                          SizedBox(height: 40,),

                           Expanded(
                            child: GestureDetector(
                              
                              onTap: (){
                                if(selectedVehicleType!=""){
                                  saveRequestInformation(selectedVehicleType);
                                }else{
                                  Fluttertoast.showToast(msg: "Please select a vehicle from \n Suggested rides.");
                                }
                              },
                              child: Container(
                                
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Request a Worker",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            )
                           ), 
                      ],
                    ),
                  ),
                )),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0 ,
                  child: Container(
                    height: searchingForWorkerContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    ),

                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                            color: Colors.blue,
                          ),

                          SizedBox(height: 10,),

                          Center(
                            child: Text(
                              "Search for a worker...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          GestureDetector(
                            onTap: () {
                              referenceRideRequest!.remove();
                              setState(() {
                                searchingForWorkerContainerHeight=0;
                                suggestedRidesContainerHeight=0;
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(width: 1, color: Colors.grey),
                              ),
                              child: Icon(Icons.close, size: 25,),
                            ),
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Container(
                            width: double.infinity,
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                      )
                  ),
                )

            /*Positioned(
                top: 40,
                right: 20,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    Provider.of<AppInfo>(context).userPickUpLocation != null
                        ? (Provider.of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!)
                                .substring(0, 24) +
                            "..."
                        : "Not Getting Address",
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ))*/
          ],
        ),
      ),
    );
  }
}
