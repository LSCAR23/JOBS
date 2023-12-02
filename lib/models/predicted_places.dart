class PredictedPlaces{
  String? place_id;
  String? main_text;
  String? secundary_text;

  PredictedPlaces({this.place_id,this.main_text,this.secundary_text});

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData){
    place_id= jsonData["place_id"];
    main_text= jsonData["structured_formatting"]["main_text"];
    secundary_text= jsonData["structured_formatting"]["secundary_text"];
  }
}