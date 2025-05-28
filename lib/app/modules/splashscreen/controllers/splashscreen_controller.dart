import 'package:decider/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:onepref/onepref.dart';

class SplashscreenController extends GetxController {
  var iApEngine = IApEngine();
  var accountType = 'Free'.obs;

  void onInit() {
    listenToPurchaseStream();
    super.onInit();
  }

  void listenToPurchaseStream() {
    iApEngine.inAppPurchase.purchaseStream.listen(
      (purchases) {
        if (purchases.isNotEmpty) {
          _upgradeAccountType();
        } else {
          _downgradeAccountType();
        }
      },
      onDone: () => Get.offAllNamed(Routes.HOME),
      onError: (error) {
        print('Error: $error');
        Get.offAllNamed(Routes.HOME);
      },
    );
  }

  void _upgradeAccountType() {
    accountType.value = 'Premium';
    OnePref.setPremium(true);
  }

  void _downgradeAccountType() {
    accountType.value = 'Free';
    OnePref.setPremium(false);
  }
}
