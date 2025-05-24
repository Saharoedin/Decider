import 'dart:io';

import 'package:decider/app/data/providers/auth_provider.dart';
import 'package:decider/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';

class StoreController extends GetxController {
  var homeController = Get.put(HomeController());
  // List of Product
  var products = List<ProductDetails>.empty().obs;

  // IApEngine
  final iApEngine = IApEngine();

  // List of Product Id from the Google Store

  List<ProductId> storeProductIds = [
    ProductId(id: 'decision_5', isConsumable: true, reward: 5),
    ProductId(id: 'decision_10', isConsumable: true, reward: 10),
    ProductId(id: 'decision_20', isConsumable: true, reward: 20),
  ];

  var productStatusMessage = 'No product available!'.obs;
  var isProductAvailable = false.obs;
  var decision = 0.obs;
  void initProducts() async {
    EasyLoading.show();
    try {
      await iApEngine.getIsAvailable().then(
        (value) async {
          if (value) {
            isProductAvailable.value = true;
            await iApEngine.queryProducts(storeProductIds).then(
              (response) {
                products.addAll(response.productDetails);
              },
            );
          } else {
            isProductAvailable.value = false;
          }
          EasyLoading.dismiss();
        },
      );
    } catch (e) {
      EasyLoading.dismiss();
      isProductAvailable.value = false;
      Get.snackbar('Error', '$e');
    }
  }

  void listenPurchase(List<PurchaseDetails> list) async {
    for (var purchase in list) {
      if (purchase.status == PurchaseStatus.restored ||
          purchase.status == PurchaseStatus.purchased) {
        if (Platform.isAndroid &&
            iApEngine
                .getProductIdsOnly(storeProductIds)
                .contains(purchase.productID)) {
          final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
              iApEngine.inAppPurchase
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        }

        if (purchase.pendingCompletePurchase) {
          await iApEngine.inAppPurchase.completePurchase(purchase);
        }

        giveUserDecisions(purchase);
      }
    }
  }

  void giveUserDecisions(PurchaseDetails purchaseDetails) async {
    for (var product in storeProductIds) {
      if (product.id == purchaseDetails.productID) {
        print(product.reward);
        homeController.account.value.bank =
            homeController.account.value.bank + product.reward!;
        // OnePref.setInt('decisions', decision.value);
        // homeController.updateBankAccount(AuthProvider().currenctUser!.uid,
        //     homeController.account.value.bank);
        // Get.back();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    iApEngine.inAppPurchase.purchaseStream.listen(
      (list) {
        listenPurchase(list);
      },
    );
    initProducts();
  }
}
