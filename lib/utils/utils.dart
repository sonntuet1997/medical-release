import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/api/signature_service.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/models/custom_dio.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/widgets/spinning.dart';

String getMessage(String serviceId) {
  String messageSign = jsonEncode({
    "creator": "",
    "serviceId": "$serviceId",
    "userId": "${Get.put(GlobalController()).user.value.blockchainUserId}",
    "serviceUserId": "",
    "isActive": true
  });
  var a = utf8.encode(messageSign.toString());
  var b = base64Url.encode(a);
  var c = b.replaceAll("=", "");

  String signature = SignatureService.getSignature(
      c, Get.put(GlobalController()).user.value.privateKey.toString());

  var jsonMessage = jsonEncode({
    "message": c,
    "signature": signature,
    "pubKey": Get.put(GlobalController()).user.value.publicKey
  });
  var bytes = utf8.encode(jsonMessage);
  var message = base64Url.encode(bytes);
  message = message.replaceAll("=", "");

  return message;
}

String getMessage1(String ownerId) {
  String messageSign = jsonEncode({
    "ownerId": ownerId,
    "viewerId": Get.put(GlobalController()).user.value.blockchainUserId,
  });
  var a = utf8.encode(messageSign.toString());
  var b = base64Url.encode(a);
  var c = b.replaceAll("=", "");

  String signature = SignatureService.getSignature(
      c, Get.put(GlobalController()).user.value.privateKey.toString());

  var jsonMessage = jsonEncode({
    "message": c,
    "signature": signature,
    "pubKey": Get.put(GlobalController()).user.value.publicKey
  });
  var bytes = utf8.encode(jsonMessage);
  var message = base64Url.encode(bytes);
  message = message.replaceAll("=", "");

  return message;
}

Future<dynamic> getStatusService({required dynamic item}) async {
  CustomDio customDio = CustomDio();
  customDio.dio.options.headers["Authorization"] =
      Get.put(GlobalController()).user.value.certificate.toString();
  var response = await customDio.get(
      "/requests/view?primaryId=${item["ownerId"]}&serviceId=${item["services"][0]["id"]}");
  print(response);
  var json = jsonDecode(response.toString());
  if (json["success"] == true && (json["data"]["ownerId"] != null)) {
    return true;
  } else
    return false;
}

void showLoading() {
  showDialog(
      barrierDismissible: false,
      context: Get.context!,
      barrierColor: Colors.black12,
      builder: (builder) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    getWidth(5),
                  ),
                ),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: EdgeInsets.all(getWidth(10)),
                    child: Spinning(
                      child: Image.asset(
                        "assets/images/loading.png",
                        width: getWidth(90),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}

Future subscribe({required String token}) async {
  try {
    GlobalController globalController = Get.put(GlobalController());
    var response;
    var userID = globalController.user.value.id.toString();
    CustomDio customDio = CustomDio();
    customDio.dio.options.headers["Authorization"] =
        globalController.user.value.certificate.toString();

    response = await customDio.post("/users/$userID/notification/subscribe", {
      "data": {"token": token}
    });

    var json = jsonDecode(response.toString());
    print(json.toString());
    return (json["success"]);
  } catch (e, s) {
    print(e);
    print(s);
    return null;
  }
}
