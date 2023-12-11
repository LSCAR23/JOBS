import 'package:jobs/models/active_nearby_available_workers.dart';

class GeoFireAssistant{
  static List<ActiveNearbyAvailableWorkers> activeNearbyAvailableWorkersList=[];

  static void deleteOfflineWorkersFromList(String workerId){
    int indexNumber= activeNearbyAvailableWorkersList.indexWhere((element) => element.workerId==workerId);

    activeNearbyAvailableWorkersList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableWorkers workerWhoMove){
    int indexNumber= activeNearbyAvailableWorkersList.indexWhere((element) => element.workerId== workerWhoMove.workerId);
    activeNearbyAvailableWorkersList[indexNumber].locationLatitude= workerWhoMove.locationLatitude;
    activeNearbyAvailableWorkersList[indexNumber].locationLongitude= workerWhoMove.locationLongitude;
    
  }
}