import 'package:decider/app/data/models/question_model.dart';
import 'package:decider/app/data/providers/admob_provider.dart';
import 'package:decider/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';

class HistoryQuestion extends StatelessWidget {
  const HistoryQuestion({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Get.width,
              height: 70,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(CupertinoIcons.arrow_left),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    'Past Decisions',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 4,
              width: Get.width,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: StreamBuilder(
                stream: controller.listUserQuestionsList.value,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  if (!snapshot.hasData)
                    return Center(
                      child: Text('Data not available!'),
                    );

                  return ListView.builder(
                    shrinkWrap: true,
                    controller: ScrollController(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data.docs[index];
                      Question q =
                          Question.fromJson(doc.data() as Map<String, dynamic>);

                      if (OnePref.getPremium() == false) {
                        final isShowBanner = index % 5 == 0;

                        BannerAd? bannerAd;

                        if (isShowBanner) {
                          bannerAd = BannerAd(
                            size: AdSize.fullBanner,
                            adUnitId: AdmobProvider().bannerUnitId!,
                            listener: AdmobProvider().bannerAdListener,
                            request: AdRequest(),
                          )..load();
                        }
                      }

                      return HistoryItem(q: q);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.q,
  });

  final Question q;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      title: Text(
        'Should I ${q.query}',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '${q.answer}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text('${DateFormat('dd/MM/yyyy HH:mm').format(q.createdAt!)}'),
    );
  }
}
