import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_chain_mobile_ui/i18n.dart';
import 'package:medical_chain_mobile_ui/screens/home_page/home_page_screen.dart';
import 'package:medical_chain_mobile_ui/screens/my_account/my_account_screen.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      translations: Messages(),
      locale: Locale('ja', 'JP'),
      fallbackLocale: Locale('en', 'UK'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAccountScreen(),
    );
  }
}

