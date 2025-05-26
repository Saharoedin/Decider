import 'dart:convert';
import 'dart:io';

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

  // Get Products
  void getProducts() async {
    await iApEngine.getIsAvailable().then(
      (value) async {
        if (value) {
          await iApEngine.queryProducts(storeProductIds).then(
            (productDetailResponse) {
              products.clear();
              products.addAll(productDetailResponse.productDetails);
            },
          );
        }
      },
    );
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
    iApEngine.inAppPurchase.purchaseStream.listen(
      (list) {
        listenPurchase(list);
      },
    );
    getProducts();

    isSubscribed.value = OnePref.getPremium() ?? false;
    super.onInit();
  }
}
