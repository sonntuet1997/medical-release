import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/my_account/my_account_controller.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';

class EditMyAccountController extends GetxController {
  MyAccountController myAccountController = Get.put(MyAccountController());

  TextEditingController name = TextEditingController();
  TextEditingController alphabetName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController citizenCode = TextEditingController();
  TextEditingController dob = TextEditingController();
  late DateTime birthday = myAccountController.dob.value;
  late RxInt avatar;

  @override
  void onInit() {
    avatar = myAccountController.avatar.value.obs;
    name.text = myAccountController.fullName.value;
    alphabetName.text = myAccountController.alphabetName.value;
    dob.text = TimeService.dateTimeToString4(myAccountController.dob.value);
    email.text = myAccountController.email.value;
    phone.text = myAccountController.phoneNumber.value;
    citizenCode.text = myAccountController.citizenCode.value;
    super.onInit();
  }

}