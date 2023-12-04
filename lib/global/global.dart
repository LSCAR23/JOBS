import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobs/models/direction_details_info.dart';
import 'package:jobs/models/user_model.dart';
final FirebaseAuth firebaseAuth= FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
DirectionsDetailsInfo? tripDirectionsDetailsInfo;
String userDropOffAddress="";