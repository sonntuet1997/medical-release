import 'package:dio/dio.dart';
import 'package:medical_chain_mobile_ui/models/status.dart';

class ResponseValidator {
  static Status check(Response? response) {
    if (response == null) {
      return new Status(status: "ERROR.SERVER", message: "EMPTY.SERVER");
    }
    if (response.data["code"] == 401) {
      return new Status(status: "ACCOUNT.BANNED", message: "ACCOUNT.BANNED");
    }
    if (response.data["code"] != 200 && response.data["code"] != 204) {
      return new Status(
          status: "ERROR.SERVER", message: response.data["reason"].toString());
    }
    return new Status(status: "OK", message: "");
  }

  static Status checkAuth(Response response, String id) {
    if (response == null) {
      return new Status(status: "ERROR.SERVER", message: "EMPTY.SERVER");
    }
    if (response.data["SUCCESS"] == false || response.data["code"] != 200) {
      return new Status(
          status: "ERROR.SERVER", message: response.data["reason"].toString());
    }
    if (id != response.data["data"]["_id"]) {
      return new Status(
          status: "NOT.AUTH", message: "PLEASE.LOGOUT.AND.RE-LOGIN");
    }
    return new Status(status: "OK", message: "");
  }
}
