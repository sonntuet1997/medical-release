import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/login_page/login_page_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/my_account/edit_my_account_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/my_account/my_account_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/signup_page/signup_page_controller.dart';
import 'package:medical_chain_mobile_ui/screens/forgot_password/forgot_password_screen.dart';
import 'package:medical_chain_mobile_ui/screens/home_page/home_page_screen.dart';
import 'package:medical_chain_mobile_ui/screens/login_page/login_welcome_page.dart';
import 'package:medical_chain_mobile_ui/screens/my_account/edit_my_account_screen.dart';
import 'package:medical_chain_mobile_ui/screens/signup_pape/signup_screen.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/utils/utils.dart';
import 'package:medical_chain_mobile_ui/widgets/app_bar.dart';
import 'package:medical_chain_mobile_ui/widgets/bounce_button.dart';
import 'package:medical_chain_mobile_ui/widgets/input.dart';

class LoginPageScreen extends StatelessWidget {
  LoginPageController loginController = Get.put(LoginPageController());

  @override
  Widget build(BuildContext context) {
    loginController.username.text = "";
    loginController.password.text = "";
    loginController.messValidatePassword.value = "";
    loginController.messValidateUsername.value = "";
    return WillPopScope(
      onWillPop: () async {
        Get.off(LoginWelcomePage());
        return true;
      },
      child: Scaffold(
        appBar: appBar(context, "ログイン", null, false, true),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: EdgeInsets.only(
            left: getWidth(16),
            right: getWidth(16),
            top: getHeight(62),
          ),
          child: Column(
            children: [
              inputRegular(context,
                  hintText: "userId".tr,
                  textEditingController: loginController.username,
                  onChange: () {
                loginController.messValidateUsername.value = "";
              }),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: getHeight(12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  "ユーザーID、メールアドレスまたは電話番号",
                  style: TextStyle(
                    fontSize: getWidth(13),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Obx(
                () => inputPassword(
                    context,
                    loginController.password,
                    "password".tr,
                    loginController.isHidePassword.value,
                    loginController.changeHidePassword, () {
                  loginController.messValidatePassword.value = "";
                }),
              ),
              SizedBox(
                height: getHeight(24),
              ),
              InkWell(
                child: Text("forgotPassword".tr),
                onTap: () {
                  print('forgot password');
                  Get.to(() => ForgotPasswordScreen());
                },
              ),
              SizedBox(
                height: getHeight(24),
              ),
              Bouncing(
                child: Container(
                  width: getWidth(double.infinity),
                  height: getHeight(48),
                  color: Color(0xFFD0E8FF),
                  alignment: Alignment.center,
                  child: Text('login'.tr),
                ),
                onPress: () async {
                  // FocusScope.of(context).unfocus();
                  try {
                    if (loginController.isClick == false) {
                      loginController.isClick = true;
                      showLoading();
                      bool result = await loginController.login();
                      if (result) {
                        var info =
                            await Get.put(MyAccountController()).getUserInfo();
                        if (info != {}) {
                          MyAccountController myAccountController =
                              Get.put(MyAccountController());
                          if (myAccountController.kanjiName.value == "") {
                            Get.back();
                            Get.put(EditMyAccountController()).signup.value =
                                true;
                            Get.put(EditMyAccountController()).dob.text =
                                TimeService.dateTimeToString4(DateTime.now());
                            Get.to(() => EditMyAccountScreen());
                          } else {
                            Get.back();
                            Get.offAll(() => HomePageScreen());
                            Get.put(GlobalController()).onChangeTab(0);
                          }
                          // loginController.username.clear();
                          // loginController.password.clear();
                        } else {
                          Get.back();
                        }
                      } else {
                        Get.back();
                      }

                      loginController.isClick = false;
                    }
                  } catch (E) {
                    Get.back();
                    loginController.isClick = false;
                  }
                },
              ),
              Obx(
                () => (loginController.messValidateUsername.value != "" ||
                        loginController.messValidatePassword.value != "")
                    ? Padding(
                        padding: EdgeInsets.only(top: getHeight(24)),
                        child: InkWell(
                          child: Text(
                            loginController.messValidateUsername.value ==
                                    "Error Server"
                                ? "Server crash"
                                : loginController.messValidateUsername.value ==
                                        "User Banned"
                                    ? "banned_user_msg".tr
                                    : "wrongPass".tr,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {},
                        ),
                      )
                    : Container(),
              ),
              SizedBox(
                height: getHeight(24),
              ),
              InkWell(
                child: Text("signup".tr),
                onTap: () {
                  SignupPageController signupPageController =
                      Get.put(SignupPageController());

                  signupPageController.userId.text = "";
                  signupPageController.email.text = "";
                  signupPageController.phone.text = "";
                  signupPageController.password.text = "";
                  signupPageController.confirmPassword.text = "";

                  signupPageController.userIdErr.value = "";
                  signupPageController.mailErr.value = "";
                  signupPageController.phoneErr.value = "";
                  signupPageController.passwordErr.value = "";
                  signupPageController.confirmPasswordErr.value = "";
                  Get.to(() => SignupScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
