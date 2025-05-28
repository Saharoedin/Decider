import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/subscription_controller.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Subscriptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                try {
                  controller.iApEngine.inAppPurchase.restorePurchases();
                } catch (e) {
                  Get.snackbar('Error', "You don't have any subscription!",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      mainButton: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          )));
                }
              },
              child: Text(
                'Restore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        width: Get.width,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => controller.products.isEmpty
                    ? Center(
                        child: Text('No product available!',
                            style: TextStyle(fontSize: 14)))
                    : ListView.builder(
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          ProductDetails dt = controller.products[index];
                          return GestureDetector(
                            onTap: () async {
                              controller.isRestored.value = false;
                              await controller.iApEngine.inAppPurchase
                                  .restorePurchases()
                                  .whenComplete(
                                () async {
                                  await Future.delayed(
                                    Duration(seconds: 2),
                                    () async {
                                      if (controller.isSubExisting.value ==
                                              true &&
                                          controller.oldPurchaseDetails
                                                  .productID !=
                                              dt.id) {
                                        await controller.iApEngine
                                            .upgradeOrDowngradeSubscription(
                                                controller.oldPurchaseDetails,
                                                dt)
                                            .then(
                                          (value) {
                                            controller.isSubExisting.value =
                                                false;
                                          },
                                        );
                                      } else {
                                        controller.iApEngine.handlePurchase(
                                            dt, controller.storeProductIds);
                                      }
                                    },
                                  );
                                },
                              );

                              // controller.iApEngine.handlePurchase(
                              //     dt, controller.storeProductIds);
                              // if (OnePref.getPremium() == false) {
                              //   controller.iApEngine.handlePurchase(
                              //       dt, controller.storeProductIds);
                              // } else {
                              // }
                              // controller.iApEngine.inAppPurchase.purchaseStream
                              //     .listen(
                              //   (list) {
                              //     if (list.isNotEmpty) {
                              //       print('here');
                              //       controller.iApEngine
                              //           .upgradeOrDowngradeSubscription(
                              //               list[0], dt);
                              //     } else {
                              //       controller.iApEngine.handlePurchase(
                              //           dt, controller.storeProductIds);
                              //     }
                              //   },
                              // );
                            },
                            child: ListTile(
                              shape: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200)),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(dt.price),
                              subtitle: Text(dt.title),
                              trailing: Text(
                                'Subscribe',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Obx(
              () => Text(
                '${controller.isSubscribed.value ? 'Premium' : 'Free'}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: controller.isSubscribed.value
                        ? Colors.blue
                        : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
