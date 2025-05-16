import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/app/data/models/account_model.dart';
import 'package:decider/app/data/models/question_model.dart';
import 'package:decider/app/data/providers/account_provider.dart';
import 'package:decider/app/data/providers/admob_provider.dart';
import 'package:decider/app/data/providers/auth_provider.dart';
import 'package:decider/app/data/providers/question_provider.dart';
import 'package:decider/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class HomeController extends GetxController {
  TextEditingController txtQuestion = TextEditingController();
  var answerQuestion = ["yes", "no", "definitely", "not right now"];
  var question = ''.obs;
  var answer = ''.obs;
  var isEmptyText = true.obs;

  var listUserQuestionsList = Stream.empty().obs;
  var accountInformation = Stream.empty().obs;
  var account = Account(bank: 0).obs;
  var isFormAvailable = true.obs;

  void getAnswer() {
    question.value = txtQuestion.text;
    answer.value = answerQuestion[Random().nextInt(answerQuestion.length)];
  }

  void clearInput() {
    txtQuestion.clear();
    question.value = '';
    answer.value = '';
    isEmptyText.value = true;
  }

  void saveToDatabase(
    Question data,
    String uid,
  ) async {
    await QuestionProvider().saveToDatabase(data);
    // if (account.value.bank > 0) {
    // }
    account.value.uid = uid;
    account.value.bank -= 1;
    account.value.nextFreeQuestion =
        DateTime.now().add(Duration(seconds: account.value.bank == 0 ? 25 : 5));
    await AccountProvider().updateAccountInformation(account.value, uid);
    EasyLoading.showSuccess('Data successfully stored');
    await Future.delayed(Duration(seconds: 5));
    clearInput();
    if (account.value.bank == 0) {
      // isFormAvailable.value = false;
      question.value = '${data.query}';
      answer.value = '${data.answer}';
    }
  }

  void updateBankAccount(String uid) async {
    var data = Account(
      uid: uid,
      bank: 1,
      nextFreeQuestion: DateTime.now(),
    );
    await AccountProvider().updateAccountInformation(data, uid);
  }

  void getUserQuestionsList(String uid) async {
    listUserQuestionsList.value =
        await QuestionProvider().getUserQuestionsList(uid);
  }

  void getAccountInformation() {
    accountInformation.value = AccountProvider()
        .getAccountInformation('${AuthProvider().currenctUser?.uid}');

    final stream = AccountProvider()
        .getAccountInformation('${AuthProvider().currenctUser?.uid}');

    stream.listen(
      (DocumentSnapshot snanpshot) {
        if (snanpshot.exists && snanpshot.data() != null) {
          final data = snanpshot.data() as Map<String, dynamic>;
          account.value = Account.fromJson(data);
          // isFormAvailable.value = true;
        } else {
          account.value = Account(bank: 0);
          // isFormAvailable.value = true;
        }
      },
    );
  }

  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  var isBannerAdReady = false.obs;
  var isIntertitialAdReady = false.obs;
  var isRewardReady = false.obs;

  void initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdmobProvider().bannerUnitId!,
      listener: AdmobProvider().bannerAdListener,
      request: AdRequest(),
    )..load();

    if (bannerAd != null) {
      isBannerAdReady.value = true;
    }
  }

  void initIntertitialAd() {
    InterstitialAd.load(
      adUnitId: AdmobProvider().interstitialUnitId!,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isIntertitialAdReady.value = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          interstitialAd = null;
        },
      ),
    );
  }

  @override
  void onInit() {
    getAccountInformation();
    super.onInit();
  }

  @override
  void onClose() {
    bannerAd?.dispose(); // penting: bersihkan resource
    super.onClose();
  }
}
