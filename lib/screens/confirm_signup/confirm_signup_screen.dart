import 'package:flutter/material.dart';
import 'package:medical_chain_mobile_ui/controllers/signup_page/signup_page_controller.dart';
import 'package:medical_chain_mobile_ui/screens/signup_pape/signup_success_screen.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/widgets/bounce_button.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class ConfirmSignupScreen extends StatelessWidget {
  SignupPageController signupPageController = Get.put(SignupPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context, "confirmSignup".tr),
        body: Container(
          height: double.infinity,
          margin: EdgeInsets.only(
            left: getWidth(16),
            right: getWidth(16),
          ),
          child: Column(
            children: [
              SizedBox(
                height: getHeight(62),
              ),
              RichText(
                text: TextSpan(
                  text: signupPageController.email.text,
                  style: TextStyle(
                    color: Color(0xFF2F3842),
                    fontSize: getWidth(17),
                  ),
                  children: [
                    TextSpan(
                      text: "confirmEmailMessage".tr,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: getHeight(22),
              ),
              Obx(() {
                // bool success = signupPageController.confirmSuccess.value;
                return PinCodeTextField(
                  onTextChanged: (text) {
                    signupPageController.confirmButtonActive();
                  },
                  hasError: !signupPageController.confirmSuccess.value,
                  autofocus: false,
                  maxLength: 6,
                  controller: signupPageController.otp,
                  isCupertino: true,
                  pinBoxWidth: getWidth(46),
                  pinBoxHeight: getHeight(67),
                  defaultBorderColor: Color(0xFFDDDEE2),
                  hasTextBorderColor: Color(0xFFDDDEE2),
                  pinBoxRadius: 4,
                  pinBoxBorderWidth: 1,
                  errorBorderColor: Colors.red,
                  pinTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: getHeight(20),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  pinBoxOuterPadding: EdgeInsets.only(left: 13),
                );
              }),
              Obx(() => signupPageController.confirmSuccess.value
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(
                        top: getHeight(12),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "emailCodeNotMatch".tr,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: getWidth(13),
                        ),
                      ),
                    )),
              SizedBox(
                height: getHeight(26),
              ),
              Bouncing(
                child: Text(
                  "emailResend".tr,
                  style: TextStyle(
                    color: Color(0xFF2F3842),
                    fontSize: getWidth(17),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPress: () {},
              ),
              SizedBox(
                height: getHeight(106),
              ),
              Obx(() {
                bool active = signupPageController.confirmActive.value;

                return GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    height: getHeight(48),
                    width: getWidth(343),
                    decoration: BoxDecoration(
                      color: active ? Color(0xFFD0E8FF) : Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "confirm".tr,
                      style: TextStyle(
                        fontSize: getWidth(17),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (active) {

                      if (signupPageController.otpValidate()) {
                        signupPageController.signup(context);
                        Get.to(() => SignupSuccessScreen());
                      }
                    }
                  },
                );
              }),
            ],
          ),
        ));
  }
}
