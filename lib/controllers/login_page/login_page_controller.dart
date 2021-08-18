import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/api/certificate_service.dart';
import 'package:medical_chain_mobile_ui/api/signature_service.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/models/User.dart';
import 'package:medical_chain_mobile_ui/models/custom_dio.dart';
import 'package:medical_chain_mobile_ui/models/status.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';
import 'package:medical_chain_mobile_ui/services/response_validator.dart';

class LoginPageController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  var isHidePassword = true.obs;
  var isHideConfirmPassword = true.obs;

  var messValidateUsername = "".obs;
  var messValidatePassword = "".obs;

  @override
  void onInit() {
    password.addListener(() {
      messValidatePassword.value = "";
    });
    username.addListener(() {
      messValidateUsername.value = "";
    });
    super.onInit();
  }

  void changeHidePassword() {
    isHidePassword.value = !isHidePassword.value;
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
      response = await customDio.post("/auth/credential", {
        "data": username,
      });
      return response;
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future signup(String username, String password) async {
    try {
      Map<String, dynamic> keyPair = generateKeyPairAndEncrypt(password);
      Response response;
      CustomDio customDio = CustomDio();
      response = await customDio.post("/user", {
        "publicKey": keyPair["publicKey"],
        "encryptedPrivateKey": keyPair["encryptedPrivateKey"],
        "displayName": username,
        "username": username,
      });
      return response;
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  Future<bool> login(context) async {
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
        var userName = data["username"];
        String? privateKey =
            decryptAESCryptoJS(encryptedPrivateKey, password.text);
        
        print(privateKey);
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
          String times = TimeService.getTimeNow().toString();
          List<String> certificateList = SignatureService.getCertificateLogin(
              certificateInfo,
              userId,
              email,
              userName,
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
            userInfo.password = password.text;
            userInfo.certificate = certificateList[0];
            print("dscds: " + userInfo.certificate.toString());
            Get.put(GlobalController()).db.put("user", userInfo);
            Get.put(GlobalController()).user.value = userInfo;
            return true;
          } else {
            messValidatePassword.value = "Wrong password";
          }
        } else {
          messValidatePassword.value = "Wrong password";
        }
      } else {
        messValidateUsername.value = "Username Invalid";
      }
    }
    return false;
  }
}
