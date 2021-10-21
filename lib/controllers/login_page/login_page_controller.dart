import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/api/certificate_service.dart';
import 'package:medical_chain_mobile_ui/api/signature_service.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/my_account/my_account_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/privacy/privacy_controller.dart';
import 'package:medical_chain_mobile_ui/models/User.dart';
import 'package:medical_chain_mobile_ui/models/custom_dio.dart';
import 'package:medical_chain_mobile_ui/models/status.dart';
import 'package:medical_chain_mobile_ui/services/db_service.dart';
import 'package:medical_chain_mobile_ui/services/response_validator.dart';

class LoginPageController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  var isHidePassword = true.obs;
  var isHideConfirmPassword = true.obs;

  var messValidateUsername = "".obs;
  var messValidatePassword = "".obs;

  bool isClick = false;

  @override
  void onInit() {
    // password.addListener(() {
    //   messValidatePassword.value = "";
    // });
    // username.addListener(() {
    //   messValidateUsername.value = "";
    // });
    super.onInit();
  }

  void changeHidePassword() {
    isHidePassword.value = !isHidePassword.value;
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

  Future unSubcribe({required String token}) async {
    try {
      GlobalController globalController = Get.put(GlobalController());
      var response;
      var userID = globalController.user.value.id.toString();
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();

      response =
          await customDio.post("/users/$userID/notification/unsubscribe", {
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

  Future fetchNoti() async {
    try {
      GlobalController globalController = Get.put(GlobalController());
      var response;
      var userID = globalController.user.value.id.toString();
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();

      response = await customDio.post("/users/$userID/notification/fetch", {});

      var json = jsonDecode(response.toString());
      print(json.toString());
      return (json["success"]);
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future getPing(List<String> certificateList) async {
    try {
      CustomDio customDio = new CustomDio();
      print({"certificate": certificateList[0]});
      // var certificateJson = jsonDecode(certificate);
      customDio.dio.options.headers["Authorization"] = certificateList[0];
      var response = await customDio.post(
        "/auth/ping",
        certificateList[1],
        sign: false,
      );
      print({"res": response});
      return response;
    } catch (e, s) {
      print({'s': s});
      return null;
    }
  }

  Future getCredential(String username) async {
    try {
      var response;
      CustomDio customDio = CustomDio();
      response = await customDio.post(
          "/auth/credential",
          {
            "data": username,
          },
          sign: false);
      return response;
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future<bool> login() async {
    User userInfo = User();
    if (username.text == "") {
      messValidateUsername.value = "Username can not be empty";
    } else if (password.text == "") {
      messValidatePassword.value = "Password can not be empty";
    } else {
      var responseCredential = await getCredential(username.text);
      print(responseCredential.toString());
      Status validateUsername = ResponseValidator.check(responseCredential);
      if (validateUsername.status == "OK") {
        print({"data": responseCredential});
        var data = responseCredential.data["data"];
        var userId = data["id"];
        var publicKey = data['publicKey'];
        var encryptedPrivateKey = data['encryptedPrivateKey'];
        var email = data["mail"];
        var userName = username.text;
        String? privateKey =
            decryptAESCryptoJS(encryptedPrivateKey, password.text);

        print("pK:" + privateKey.toString());
        Status validatePassword = new Status();

        if (privateKey == null)
          validatePassword =
              new Status(status: "ERROR", message: "WRONG.PASSWORD");
        else
          validatePassword = new Status(status: "SUCCESS", message: "SUCCESS");

        if (validatePassword.status == "SUCCESS") {
          var certificateInfo = SignatureService.getCertificateInfo(userId);
          print(certificateInfo);
          String signature = SignatureService.getSignature(
              certificateInfo, privateKey as String);
          int times = DateTime.now().toUtc().millisecondsSinceEpoch;
          List<String> certificateList = SignatureService.getCertificateLogin(
              certificateInfo,
              userId,
              privateKey,
              encryptedPrivateKey,
              signature,
              publicKey,
              times);

          var responsePing = await getPing(certificateList);
          print({"resPing": responsePing.toString()});
          Status validateServer2 = ResponseValidator.check(responsePing);
          if (validateServer2.status == "OK") {
            userInfo.id = userId;
            userInfo.name = userName;
            userInfo.phone = data["phone"];
            userInfo.mail = email;
            userInfo.publicKey = publicKey;
            userInfo.privateKey = privateKey;
            userInfo.encryptedPrivateKey = encryptedPrivateKey;
            userInfo.username = username.text;
            userInfo.certificate = certificateList[0];
            userInfo.blockchainUserId =
                responsePing.data["data"]["blockchainIndex"];
            print("dscds: " + userInfo.certificate.toString());
            await initDBLogin();
            Get.put(GlobalController()).db.put("user", userInfo);
            Get.put(GlobalController()).user.value = userInfo;
            String? token = await FirebaseMessaging.instance.getToken();
            print(token.toString());
            var subcribeRes = await subscribe(token: token.toString());
            print(subcribeRes);
            var info = await Get.put(MyAccountController()).getUserInfo();
            Get.put(PrivacyController()).checkPrivacy();
            var fetnoti = await fetchNoti();
            // username.clear();
            // password.clear();
            return true;
          } else {
            if (validateServer2.status == "ACCOUNT.BANNED")
              messValidateUsername.value = "User Banned";
            else
              messValidatePassword.value = "Wrong password";
          }
        } else {
          messValidatePassword.value = "Wrong password";
        }
      } else if (validateUsername.status == "ERROR.SERVER") {
        messValidateUsername.value = "Error Server";
      } else if (validateUsername.status == "ACCOUNT.BANNED") {
        messValidateUsername.value = "User Banned";
      } else {
        messValidateUsername.value = "Username Invalid";
      }
    }
    return false;
  }
}
