import 'package:flutter/material.dart';
import 'package:jobs/infoHandler/app_info.dart';
import 'package:jobs/widgets/history_design_ui.dart';
import 'package:provider/provider.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    //bool darkTheme= false;
    return Scaffold(
      backgroundColor: darkTheme? Colors.black: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme? Colors.black:Colors.white,
        title: Text(
          "Trips History",
          style: TextStyle(
            color: darkTheme? Colors.amber.shade400:Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.close,color: darkTheme?Colors.amber.shade400:Colors.black,),
      ),
      centerTitle: true,
      elevation: 0,
    ),
    body: Padding(
      padding:EdgeInsets.all(20),
      child: ListView.separated(
        itemBuilder: (context,i){
          return Card(
            color: Colors.grey[100],
            shadowColor: Colors.transparent,
            child: HistoryDesignUIWidget(
              tripHistoryModel: Provider.of<AppInfo>(context,listen: false).allTripHistoryInformationList[i],
            ),
          );
        }, 
        separatorBuilder: (context, i)=> SizedBox(height: 30,), 
        itemCount: Provider.of<AppInfo>(context,listen: false).allTripHistoryInformationList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ), 
    ),
   );
  }
}