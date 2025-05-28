import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';

class SubscriptionController extends GetxController {
  // List of Products
  var products = List<ProductDetails>.empty().obs;

  // List of ProductIds
  final List<ProductId> storeProductIds = [
    ProductId(
        id: 'unlimited_montly', isConsumable: false, isSubscription: true),
  ];

  //IApEngine
  var iApEngine = IApEngine();

  // bool
  var isSubscribed = false.obs;
  var isSubExisting = false.obs;
  var isRestored = false.obs;
  late PurchaseDetails oldPurchaseDetails;

  // Get Products
  Future<void> fetchProducts() async {
    final isAvailable = await iApEngine.getIsAvailable();
    if (isAvailable) {
      final productDetailsResponse =
          await iApEngine.queryProducts(storeProductIds);
      products.value = productDetailsResponse.productDetails;
    }
  }

  // List to our product
  Future<void> listenPurchase(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      for (var purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.restored ||
            purchaseDetails.status == PurchaseStatus.purchased) {
          Map purchaseData = jsonDecode(
              purchaseDetails.verificationData.localVerificationData);
          if (purchaseData['acknowledged']) {
            isSubscribed.value = true;
            OnePref.setPremium(isSubscribed.value);
          } else {
            if (Platform.isAndroid) {
              final InAppPurchaseAndroidPlatformAddition
                  androidPlatformAddition = iApEngine.inAppPurchase
                      .getPlatformAddition<
                          InAppPurchaseAndroidPlatformAddition>();
              await androidPlatformAddition
                  .consumePurchase(purchaseDetails)
                  .then(
                (value) {
                  isSubscribed.value = true;
                  OnePref.setPremium(isSubscribed.value);
                },
              );
            }

            if (purchaseDetails.pendingCompletePurchase) {
              await iApEngine.inAppPurchase
                  .completePurchase(purchaseDetails)
                  .then(
                (value) {
                  isSubscribed.value = true;
                  OnePref.setPremium(isSubscribed.value);
                },
              );
            }
          }
        }
      }
    } else {
      isSubscribed.value = false;
      OnePref.setPremium(isSubscribed.value);
    }
  }

  @override
  void onInit() {
    isSubscribed.value = OnePref.getPremium() ?? false;

    iApEngine.inAppPurchase.purchaseStream.listen(
      (list) {
        listenPurchase(list);

        if (list.isNotEmpty) {
          isSubExisting.value = true;
          oldPurchaseDetails = list[0];
        }

        // if (list.isEmpty || isRestored.value == false) {
        //   Get.snackbar(
        //     'Restore',
        //     'You have no purchases to restore',
        //     snackPosition: SnackPosition.BOTTOM,
        //     duration: const Duration(seconds: 2),
        //     backgroundColor: Colors.red.withOpacity(0.5),
        //     colorText: Colors.white,
        //   );
        // } else {
        //   Get.snackbar(
        //     'Restore',
        //     'Congratulations! Your purchases have been restored',
        //     snackPosition: SnackPosition.BOTTOM,
        //     duration: const Duration(seconds: 2),
        //     backgroundColor: Colors.green.withOpacity(0.5),
        //     colorText: Colors.white,
        //   );
        // }
      },
    ).onDone(
      () {
        print('Purchase Stream Done');
      },
    );

    fetchProducts();

    isSubscribed.value = OnePref.getPremium() ?? false;
    super.onInit();
  }
}
