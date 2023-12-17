import 'package:flutter/material.dart';
import 'package:jobs/splash_screen/splash_screen.dart';

class PayFareAmountDialog extends StatefulWidget {
  double? fareAmount;

  PayFareAmountDialog({this.fareAmount});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {

    //bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    bool darkTheme= true;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            SizedBox(height: 20,),

            Text("Fare Amount".toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 20,),

          Divider(
            thickness: 2,
            color: Colors.white,
          ),

          SizedBox(height: 10,),

          Text(
            "₡ "+widget.fareAmount.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 50,
            ),
          ),

          SizedBox(height: 10,),

          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "This is the total fare amount. Please pay it to the driver",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ), 
          ),

          SizedBox(height: 10,),

          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),

              onPressed: (){
                Future.delayed(Duration(milliseconds: 10000),(){
                  Navigator.pop(context,"Cash Paid");
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));

                });

              },

              child: Row(
                children: [
                  Text(
                  "Pay Cash ",
                  style:TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  )
                  ),

                  Text(
                    "₡"+widget.fareAmount.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  )

                ],
              ),
            ),
          )

          ],
        ),
      ),
    );
  }
}