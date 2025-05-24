import 'package:decider/app/data/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await OnePref.init();
  await Firebase.initializeApp();
  await AuthProvider().getOrCreateUser();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: AuthProvider()),
      ],
      child: DeciderApp(),
    ),
  );
}

class DeciderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Decider",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    );
  }
}
