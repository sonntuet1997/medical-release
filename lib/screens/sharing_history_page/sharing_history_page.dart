import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/home_page/home_page_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/share_history_page/share_history_controller.dart';
import 'package:medical_chain_mobile_ui/screens/home_page/home_page_screen.dart';
import 'package:medical_chain_mobile_ui/screens/sharing_history_page/sharing_history_details_component.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/widgets/app_bar.dart';
import 'package:medical_chain_mobile_ui/widgets/input.dart';
import 'package:medical_chain_mobile_ui/widgets/search_navigator.dart';
import 'package:medical_chain_mobile_ui/widgets/text_box.dart';

class ShareHistoryPage extends StatelessWidget {
  GlobalController globalController = Get.put(GlobalController());
  ShareHistoryController sharingHistoryController =
      Get.put(ShareHistoryController());
  @override
  Widget build(BuildContext context) {
    var mode = globalController.historyStatus.value;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(
        context,
        mode == "SENDING_MODE" ? 'viewDataShare'.tr : "viewDataRequest".tr,
        null,
        true,
      ),
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          Get.put(HomePageController()).currentPage.value = 0;
          Get.offAll(HomePageScreen());
          return true;
        },
        child: Column(children: [
          inputSearch(
            context,
            hintText: "ユーザーID、氏名、ニックネームで検索",
            textEditingController: sharingHistoryController.searchInput,
            onSearch: sharingHistoryController.search,
          ),
          sharingHistoryNavigator(controller: sharingHistoryController),
          Obx(
            () => sharingHistoryController.isHideNotiSearch.value
                ? Container(
                    color: Color(0xFFF6F7FB),
                    height: getHeight(20),
                  )
                : customBoxHeader(sharingHistoryController.searchInput.text +
                    " で " +
                    sharingHistoryController.searchList.length.toString() +
                    "結果は出ました。"),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFF6F7FB),
              child: PageView(
                controller: sharingHistoryController.pageController,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(5, (index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Obx(
                      () => ListView(
                        children: sharingHistoryController.searchList
                            .map((e) => historyDetailComponent(record: e))
                            .toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
