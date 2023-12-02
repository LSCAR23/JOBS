import 'package:flutter/material.dart';
import 'package:jobs/Assistants/request_assistant.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/global/map_key.dart';
import 'package:jobs/infoHandler/app_info.dart';
import 'package:jobs/models/directions.dart';
import 'package:jobs/models/predicted_places.dart';
import 'package:jobs/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

class PlacePredictionTitleDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTitleDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTitleDesign> createState() =>
      _PlacePredictionTitleDesignState();
}

class _PlacePredictionTitleDesignState
    extends State<PlacePredictionTitleDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting up Drop-Off. Please wait...",
            ));
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if (responseApi == "Error Occured. Failed. No Response.") {
      return;
    }

    if(responseApi["status"]=="OK"){
      Directions directions= Directions();
      directions.locationName=responseApi["result"]["name"];
      directions.locationId= placeId;
      directions.locationLatitude= responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude= responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress= directions.locationName!;
      });
      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
            primary: darkTheme ? Colors.black : Colors.white),
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  Icons.add_location,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaces!.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      ),
                    ),
                    Text(
                      widget.predictedPlaces!.secundary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      ),
                    )
                  ],
                ))
              ],
            )));
  }
}
