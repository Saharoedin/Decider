import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splashscreen_controller.dart';

class SplashscreenView extends GetView<SplashscreenController> {
  const SplashscreenView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(SplashscreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/img-logo.png',
                width: Get.width * 0.5,
              ),
            ),
          ),
          Obx(() => GestureDetector(
              onTap: () {
                controller.listenToPurchaseStream();
              },
              child: Text('Account Type : ${controller.accountType.value}')))
        ],
      ),
    );
  }
}
