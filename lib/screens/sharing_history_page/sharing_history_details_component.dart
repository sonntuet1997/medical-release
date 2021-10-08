import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/global_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/notification/notification_controller.dart';
import 'package:medical_chain_mobile_ui/controllers/share_history_page/share_history_controller.dart';
import 'package:medical_chain_mobile_ui/services/date_format.dart';
import 'package:medical_chain_mobile_ui/utils/common-function.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';

import 'detail_history_page.dart';

Widget historyDetailComponent({required record}) {
  ShareHistoryController shareHistoryController =
      Get.put(ShareHistoryController());
  GlobalController globalController = Get.put(GlobalController());
  List<dynamic> serviceList = record["services"];
  var mode = globalController.historyStatus.value == "SENDING_MODE";
  var subMode = ["sharing", "expired"].contains(record["status"]);
  return GestureDetector(
    onTap: () async {
      if (record["status"] != "invalid") {
        var item = await Get.put(NotificationController())
            .getRequest(id: record["id"]);
        shareHistoryController.itemSelected.value = item;
        Get.to(() => DetailHistoryPage());
      }
    },
    child: Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        left: getWidth(16),
        right: getWidth(16),
        bottom: getHeight(20),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: getWidth(16),
              bottom: getHeight(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                    'assets/images/jp_${record["status"]}_tag.svg'),
                // Text(
                //   "${record["status"]}_color".tr,
                //   style: TextStyle(color: Colors.red, fontSize: getWidth(13)),
                // ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: getWidth(16),
              bottom: getHeight(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(mode
                    ? (subMode ? 'dataReceiver'.tr : 'requestSender'.tr + ':')
                    : (subMode ? 'dataSender'.tr : 'requestReceived'.tr + ':')),
                SizedBox(
                  width: getWidth(8),
                ),
                Text(
                  getHintText(record),
                  style: TextStyle(
                      fontSize: getWidth(17), fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: getWidth(16),
              bottom: getHeight(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('data'.tr + ':'),
                SizedBox(
                  width: getWidth(8),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: serviceList
                      .map((e) => Container(
                            margin: EdgeInsets.only(
                              bottom: getHeight(8),
                            ),
                            child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(27),
                                child: Container(
                                  width: getWidth(16),
                                  height: getWidth(16),
                                  child: e["icon"].toString().contains("http")
                                      ? Image.asset(
                                          e["icon"].toString(),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          base64Decode(e["icon"]
                                              .toString()
                                              .split(",")[1]),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              // Container(
                              //   width: getWidth(16),
                              //   child: e["icon"].toString().contains('http')
                              //       ? Image.network(e["icon"].toString())
                              //       : SvgPicture.asset(
                              //           "assets/images/avatar.svg",
                              //           width: getWidth(16),
                              //         ),
                              // ),
                              SizedBox(width: getWidth(8)),
                              Container(
                                child: Text(upperFirstString(e["name"])),
                              ),
                            ]),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF8F8F9),
                  width: getHeight(3),
                ),
              ),
            ),
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: getWidth(16),
              bottom: getHeight(12),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: getHeight(15),
                bottom: getHeight(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset("assets/images/calendar.svg"),
                  SizedBox(
                    width: getWidth(8),
                  ),
                  record["status"] == "expired"
                      ? Text(
                          TimeService.getTimeFormat(record["fromTime"], "") +
                              "～" +
                              // endTime , bao h noi api that fix sau
                              TimeService.getTimeFormat(record["endTime"], ""),
                          style: TextStyle(fontSize: getWidth(13)),
                        )
                      : record["status"] == "rejected"
                          ? Text(
                              TimeService.getTimeFormat(record["endTime"], ""),
                              style: TextStyle(fontSize: getWidth(13)),
                            )
                          : Text(
                              TimeService.getTimeFormat(record["fromTime"], ""),
                              style: TextStyle(fontSize: getWidth(13)),
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
