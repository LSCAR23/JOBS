import 'dart:async';
//import 'dart:html';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLocation;
  loc.Location location=  loc.Location();
  String? _address;


  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey <ScaffoldState> _scaffoldState= GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight=220;
  double waitingResponsefromDriverContainerHeight=0;
  double assignedDriverInfoContainerHeight=0;

  Position? userCurrentPosition;

  var geoLocation= Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingofMap=0;
  
  List<LatLng> pLineCoordidatedList=[];

  Set<Polyline> polylineSet={};
  Set<Circle> circlesSet={};
  Set<Marker> markersSet={};
  //String userName="";
  //String userEmail="";

  bool openNavigationDrawer=true;

  bool activeNearbyDriverKeysLoaded= false;

  BitmapDescriptor? activeNearbyIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated:(GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController=controller;
                setState(() {
                  
                });
              },
              )
          ],
        ),
      ),
    );
  }
}