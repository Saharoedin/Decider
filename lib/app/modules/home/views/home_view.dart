import 'package:decider/app/data/models/question_model.dart';
import 'package:decider/app/data/providers/auth_provider.dart';
import 'package:decider/app/modules/home/views/history_question.dart';
import 'package:decider/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

import 'package:get/get.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    if (OnePref.getPremium() == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initBannerAd();
      });
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Decider'),
        // centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
                onTap: () => Get.toNamed(Routes.STORE),
                child: Icon(Icons.shopping_bag)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
                onTap: () {
                  controller.getUserQuestionsList(
                      '${context.read<AuthProvider>().currenctUser?.uid}');
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    barrierColor: Colors.white,
                    constraints: BoxConstraints.expand(),
                    context: context,
                    builder: (context) => HistoryQuestion(),
                  );
                },
                child: Icon(Icons.history)),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnePref.getPremium() == false
                  ? Obx(
                      () => Column(
                        children: [
                          StreamBuilder(
                            stream: controller.accountInformation.value,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return CircularProgressIndicator();

                              if (!snapshot.hasData)
                                return Text('Decision Left : ##');

                              return Text(
                                'Decision Left : ${controller.account.value.bank}',
                              );
                            },
                          ),
                          Obx(
                            () => controller.account.value.bank == 0
                                ? Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          'You will get one free decision in',
                                        ),
                                        Countdown(
                                          seconds: controller.account.value
                                                  .nextFreeQuestion
                                                  ?.difference((DateTime.now()))
                                                  .inSeconds ??
                                              0,
                                          build: (BuildContext context,
                                                  double time) =>
                                              Text(
                                                  '${NumberFormat('00', 'en_US').format(time ~/ 3600)}:${NumberFormat('00', 'en_US').format((time % 3600) ~/ 60)}:${NumberFormat('00', 'en_US').format(time.toInt() % 60)}'),
                                          interval: Duration(seconds: 1),
                                          onFinished: () {
                                            controller.clearInput();
                                            controller.updateBankAccount(
                                              context
                                                  .read<AuthProvider>()
                                                  .currenctUser!
                                                  .uid,
                                              1,
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ),
                          Obx(
                            () => controller.isRewardReady.value == true
                                ? Container(
                                    margin: EdgeInsets.only(top: 32),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.initRewardedAd(context
                                            .read<AuthProvider>()
                                            .currenctUser!
                                            .uid);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.blueAccent),
                                      ),
                                      child: Text(
                                        'Get 2 free decision',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => controller.account.value.bank > 0
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Should I ',
                                      style: TextStyle(fontSize: 32),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        controller: controller.txtQuestion,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          if (value.isEmpty) {
                                            controller.isEmptyText.value = true;
                                          } else {
                                            controller.isEmptyText.value =
                                                false;
                                          }
                                        },
                                        onFieldSubmitted: (value) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            controller.getAnswer();
                                          }
                                        },
                                        validator: (value) {
                                          if (value == '')
                                            return 'Please enter a question';
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          helperText: 'Enter A Question',

                                          // errorText: 'Pleas Enter A Question',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (controller.isEmptyText.value ==
                                            false) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (OnePref.getPremium() == false) {
                                              controller.initIntertitialAd();
                                            }
                                            controller.getAnswer();
                                            controller.saveToDatabase(
                                              Question(
                                                query:
                                                    controller.txtQuestion.text,
                                                answer: controller.answer.value,
                                                createdAt: DateTime.now(),
                                              ),
                                              '${context.read<AuthProvider>().currenctUser?.uid}',
                                            );
                                          }
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        backgroundColor: WidgetStatePropertyAll(
                                          controller.isEmptyText.value == true
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      child: Text(
                                        'Ask',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                      ),
                      Obx(
                        () => controller.question.value == ''
                            ? SizedBox()
                            : Container(
                                margin: EdgeInsets.only(top: 32),
                                child: Column(
                                  children: [
                                    Text(
                                      'Should I ${controller.question.value}?',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${controller.answer.value}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Account Type : '),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
                    child: Text(
                      '${OnePref.getPremium() == true ? 'Premium' : 'Free'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: OnePref.getPremium() == true
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Text('${context.read<AuthProvider>().currenctUser!.uid}'),
              Obx(
                () => controller.isBannerAdReady.value == true
                    ? Container(
                        margin: EdgeInsets.only(top: 16),
                        height: 60,
                        width: Get.width,
                        child: AdWidget(ad: controller.bannerAd!),
                      )
                    : SizedBox(
                        height: 16,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
