import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/store_controller.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class StoreView extends GetView<StoreController> {
  const StoreView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Decider Store',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                  onTap: () async {
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
