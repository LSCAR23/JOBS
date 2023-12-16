import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobs/models/direction_details_info.dart';
import 'package:jobs/models/user_model.dart';
final FirebaseAuth firebaseAuth= FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;

List workersList=[];
DirectionsDetailsInfo? tripDirectionsDetailsInfo;
String userDropOffAddress="";

String workerCarDetails="";
String workerName="";
String workerPhone="";

double countRatingStars=0.0;
String titleStarsRating="";

String cloudMessagingServerToken="key=AAAAFNNkI2I:APA91bE_GKOnMNIQ-7yTJ9eJMJCt1WMRkqA5CxIhV1XS6xgiwUlFvo9a0XLLQb8-GjaWoezGI9uxi3oyPz-StihIt75Bv3mAowQpuQ1qkOyx5Or-C66PjdMgHEZCXFrXB2uxIJN2PqKJ";
