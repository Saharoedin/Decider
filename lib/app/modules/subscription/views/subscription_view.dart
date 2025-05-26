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
        title: Column(
          children: [
            Text(
              'Subscriptions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                '${controller.isSubscribed.value ? '- Premium -' : '- Free - '}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: controller.isSubscribed.value
                        ? Colors.blue
                        : Colors.grey),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () =>
                  controller.iApEngine.inAppPurchase.restorePurchases(),
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
      body: Obx(() => controller.products.isEmpty
          ? Center(
              child:
                  Text('No product available!', style: TextStyle(fontSize: 14)))
          : ListView.builder(
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                ProductDetails dt = controller.products[index];
                return GestureDetector(
                  onTap: () {
                    controller.iApEngine
                        .handlePurchase(dt, controller.storeProductIds);
                  },
                  child: ListTile(
                    title: Text(dt.title),
                    subtitle: Text(dt.description),
                    trailing: Text(dt.price),
                  ),
                );
              },
            )),
    );
  }
}
