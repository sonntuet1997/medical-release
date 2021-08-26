import 'dart:convert';

import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/models/custom_dio.dart';
import 'package:medical_chain_mobile_ui/models/service.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';

class ShareServiceListController extends GetxController {
  GlobalController globalController = Get.put(GlobalController());

  var checkList = [].obs;
  var timeSelected = 0.obs;

  var fromTime;
  var endTime;

  List<Map<String, dynamic>> timeList = [
    {"value": 0, "name": "1週間"},
    {"value": 1, "name": "1か月"},
    {"value": 2, "name": "オフにするまで"}
  ];

  RxList<dynamic> serviceList = [].obs;

  @override
  void onInit() async {
    var servicesData = await getServiceList();
    serviceList.value = servicesData;
    super.onInit();
  }

  String getFormatTimeCal() {
    Duration expired = timeList[timeSelected.value]["value"] == 0
        ? Duration(days: 7)
        : Duration(days: 30);
    String selectedTime = timeList[timeSelected.value]["name"];
    String calTime =
        TimeService.stringToDJP(TimeService.getTimeNow().add(expired));

    fromTime = TimeService.timeToBackEnd(TimeService.getTimeNow());
    endTime = TimeService.timeToBackEnd(TimeService.getTimeNow().add(expired));

    if (timeList[timeSelected.value]["value"] == 2) return selectedTime;
    return selectedTime + " (" + calTime + ")";
  }

  Future shareService(
      {required String id, required String sharingStatus}) async {
    try {
      var response;
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();
      List<String> services = [];
      for (int i = 0; i < serviceList.length; i++) {
        var id = serviceList[i].id;
        services.add(id);
      }

      if (sharingStatus == "SENT_DATA") {
        response = await customDio.post("/request/share", {
          "data": {
            "secondaryId": id,
            "services": services,
            "fromTime": fromTime,
            "endTime": endTime,
          }
        });
      } else {
        response = await customDio.post("/request/ask", {
          "data": {
            "primaryId": id,
            "services": services,
            "fromTime": fromTime,
            "endTime": endTime,
          }
        });
      }

      var json = jsonDecode(response.toString());
      return (json["data"]);
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future<List<Service>> getServiceList() async {
    try {
      var userID = globalController.user.value.id.toString();
      var response;
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();
      response = await customDio.get("/user/$userID/services");
      var json = jsonDecode(response.toString());
      print(json["data"]);
      var list = json["data"];
      List<Service> listService = [];

      for (var i = 0; i < list.length; i++) {
        print(list[i]);
        Service service = new Service();
        service.id = list[i]['id'];
        service.name = list[i]['name'];
        service.url = list[i]['url'];
        service.username = list[i]['username'];
        service.isConnected = list[i]["connected"];
        listService.add(service);
      }

      return (listService);
    } catch (e, s) {
      print(e);
      print(s);
      return [];
    }
  }
}
