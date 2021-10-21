import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/share_history_page/share_history_controller.dart';
import 'package:medical_chain_mobile_ui/screens/home_page/home_page_screen.dart';
import 'package:medical_chain_mobile_ui/screens/sharing_history_page/sharing_history_details_component.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/widgets/app_bar.dart';
import 'package:medical_chain_mobile_ui/widgets/input.dart';
import 'package:medical_chain_mobile_ui/widgets/search_navigator.dart';

class ShareHistoryPage extends StatelessWidget {
  GlobalController globalController = Get.put(GlobalController());
  ShareHistoryController sharingHistoryController =
      Get.put(ShareHistoryController());
  @override
  Widget build(BuildContext context) {
    var mode = globalController.historyStatus.value;
    return WillPopScope(
      onWillPop: () async {
        globalController.onChangeTab(0);
        Get.offAll(() => HomePageScreen(), transition: Transition.leftToRight);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar(
          context,
          mode == "SENDING_MODE" ? 'viewDataShare'.tr : "viewDataRequest".tr,
          null,
          true,
        ),
        backgroundColor: Colors.white,
        body: Column(children: [
          inputSearch(
            context,
            hintText: "sharing_history_page".tr,
            textEditingController: sharingHistoryController.searchInput,
            onSearch: sharingHistoryController.search,
          ),
          sharingHistoryNavigator(controller: sharingHistoryController),
          Expanded(
            child: Container(
              color: Color(0xFFABD6FE),
              child: Column(
                children: [
                  Obx(
                    () => sharingHistoryController.isHideNotiSearch.value
                        ? Container(
                            color: Color(0xFFABD6FE),
                            height: getHeight(20),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFABD6FE),
                              border: Border.all(
                                color: Color(0xFFABD6FE),
                                width: getHeight(1),
                              ),
                            ),
                            height: getHeight(56),
                            child: Row(
                              children: [
                                SizedBox(width: getWidth(15)),
                                sharingHistoryController.searchList.length == 0
                                    ? Container()
                                    : Text(
                                        sharingHistoryController
                                                .searchInput.text +
                                            " " +
                                            "so".tr +
                                            " " +
                                            sharingHistoryController
                                                .searchList.length
                                                .toString() +
                                            "records_result".tr,
                                        style:
                                            TextStyle(fontSize: getWidth(13)),
                                      ),
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xFFABD6FE),
                      child: PageView(
                        controller: sharingHistoryController.pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(5, (index) {
                          return Container(
                            alignment: Alignment.center,
                            child: Obx(() => sharingHistoryController
                                        .searchList.length >
                                    0
                                ? ListView(
                                    children: sharingHistoryController
                                        .searchList
                                        .map((e) =>
                                            historyDetailComponent(record: e))
                                        .toList(),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: getHeight(41.15),
                                      ),
                                      Container(
                                        child: SvgPicture.asset(
                                            "assets/images/empty-records.svg"),
                                      ),
                                      SizedBox(
                                        height: getHeight(33.3),
                                      ),
                                      Text(
                                        "emptyRecords".tr,
                                        style:
                                            TextStyle(fontSize: getWidth(17)),
                                      ),
                                    ],
                                  )),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
