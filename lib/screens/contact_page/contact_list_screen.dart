import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/controllers/contact_page/contact_page_controller.dart';
import 'package:medical_chain_mobile_ui/screens/contact_page/search_user_screen.dart';
import 'package:medical_chain_mobile_ui/utils/config.dart';
import 'package:medical_chain_mobile_ui/widgets/app_bar.dart';
import 'package:medical_chain_mobile_ui/widgets/input.dart';

class ContactListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ContactPageController contactPageController =
        Get.put(ContactPageController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, "contact".tr),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: getHeight(52),
          right: getWidth(24),
        ),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF61B3FF),
          foregroundColor: Colors.white,
          onPressed: () async {
            // print(contactPageController.contactList);
            Get.to(() => SearchUserScreen());
          },
          child: Icon(Icons.add),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            inputSearch(
              context,
              hintText: "searchInput".tr,
              textEditingController: contactPageController.searchInput,
              onSearch: contactPageController.search,
            ),
            SizedBox(
              height: getHeight(12),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(getHeight(4)),
                border: Border.all(
                  color: Color(0xFFECEFF1),
                  width: getHeight(1),
                ),
              ),
              height: getHeight(56),
              child: Row(
                children: [
                  SizedBox(width: getWidth(15)),
                  Text(
                    "A",
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
            ),
            Obx(
              () => Expanded(
                  flex: 1,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: contactPageController.searchList.value
                        .map(
                          (e) => Container(
                            margin: EdgeInsets.only(
                              left: getWidth(15),
                              right: getWidth(15),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFECEFF1),
                                  width: getHeight(1),
                                ),
                              ),
                            ),
                            height: getHeight(78),
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/avatar.svg"),
                                SizedBox(width: getWidth(15)),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(e["secondaryName"]),
                                      Text(
                                        e["secondaryUsername"],
                                        style: TextStyle(
                                            color: Colors.blueGrey.shade300),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                        )
                        .toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
