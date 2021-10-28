import 'dart:convert';

import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/user_search_page/user_search_controller.dart';
import 'package:medical_chain_mobile_ui/models/custom_dio.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';

class ShareServiceListController extends GetxController {
  GlobalController globalController = Get.put(GlobalController());

  var checkList = [].obs;

  var fromTime;
  var endTime;

  RxList<dynamic> serviceList = [].obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    var servicesData = await getServiceList();
    serviceList.value = servicesData;
    super.onInit();
  }

  String getFormatTimeCal() {
    Duration expired = Duration(days: 100000);
    String calTime = TimeService.stringToDJP(TimeService.getTimeNow());

    fromTime = TimeService.timeToBackEnd(TimeService.getTimeNow());
    endTime = TimeService.timeToBackEnd(TimeService.getTimeNow().add(expired));
    return calTime;
  }

  Future shareService(
      {required String id, required String sharingStatus}) async {
    try {
      var response;
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();
      List<String> services = [];
      for (int i = 0; i < checkList.length; i++) {
        var id = checkList[i]["id"];
        services.add(id);
      }

      if (sharingStatus == "SENT_DATA") {
        response = await customDio.post("/requests/share", {
          "data": {
            "secondaryId": id,
            "services": services,
            "fromTime": fromTime,
          }
        });
      } else {
        response = await customDio.post("/requests/ask", {
          "data": {
            "primaryId": id,
            "services": services,
            "fromTime": fromTime,
          }
        });
      }

      var json = jsonDecode(response.toString());
      print(json["error"]);

      if (json["success"] == false &&
          json["error"] == "ERROR.API.SERVICES_ALREADY_SHARED") {
        print('debug di vao day');
        var servicesNotConnectedData = json["data"]["services"];
        var servicesNotConnectedList = [];
        for (var j = 0; j < servicesNotConnectedData.length; j++) {
          var service = {};
          service["id"] = servicesNotConnectedData[j]["id"];
          service["name"] = servicesNotConnectedData[j]["name"];
          service["icon"] = servicesNotConnectedData[j]["icon"];
          servicesNotConnectedList.add(service);
        }
        return {"services": servicesNotConnectedList, "success": false};
      }

      return (json["data"]);
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getServiceList() async {
    try {
      isLoading.value = true;
      var userID = globalController.user.value.id.toString();
      var response;
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();
      if (globalController.sharingStatus.value == "SENT_DATA")
        response = await customDio.get(
            "/requests/services?primaryId=$userID&secondaryId=${Get.put(UserSearchController()).userData["secondaryId"]}");
      else
        response = await customDio.get(
            "/requests/services?primaryId=${Get.put(UserSearchController()).userData["secondaryId"]}&secondaryId=$userID");
      var json = jsonDecode(response.toString());
      print(json["data"]);
      var list = json["data"]["results"];
      List<Map<String, dynamic>> listService = [];

      for (var i = 0; i < list.length; i++) {
        print(list[i]);
        Map<String, dynamic> service = {};
        service["id"] = list[i]['id'];
        service["name"] = list[i]['name'];
        service["url"] = list[i]['url'];
        service["username"] = list[i]['username'];
        service["isConnected"] = list[i]["connected"] ?? false;
        service["icon"] = list[i]["icon"];
        service["status"] = list[i]["status"] ?? "";
        listService.add(service);
      }
      isLoading.value = false;

      return (listService);
    } catch (e, s) {
      isLoading.value = false;
      print(e);
      print(s);
      return [];
    }
  }
}
