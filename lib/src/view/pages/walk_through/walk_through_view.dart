import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/app_router.dart';
import 'package:tree/gen/assets.gen.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/flutter_onboarding_slider.dart';
import 'package:tree/src/view/widgets/on_boarding_page.dart';

class WalkThroughView extends StatelessWidget {
  final List<OnBoardingPage> list = [
    OnBoardingPage(
      image: Assets.images.tutorial.a1.image(width: 300, height: 300),
      title: "Tree",
      description: "Treeはシンプルなメモアプリです",
    ),
    OnBoardingPage(
      image: Assets.images.tutorial.a2.image(width: 300, height: 300),
      title: "操作が直感的",
      description: "ページ上部にあるボタンで直感的に操作できます",
    ),
    OnBoardingPage(
      image: Assets.images.tutorial.a3.image(width: 534, height: 300),
      title: "テンプレート運用も可能",
      description: "コピー機能を活用すればテンプレート運用も可能です",
    ),
    OnBoardingPage(
      image: Assets.images.tutorial.a4.image(width: 300, height: 300),
      title: "データシェアも簡単",
      description: "データを独自形式や.txt形式で簡単にシェアできます",
    ),
    OnBoardingPage(
      image: null,
      title: "さあ、始めましょう！",
      description: "",
    ),
  ];

  WalkThroughView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, widget) {
      return OnBoardingSlider(
        headerBackgroundColor: Colors.blue,
        pageBackgroundColor: Colors.blue,
        controllerColor: Colors.white,
        speed: 0,
        totalPage: 5,
        centerBackground: true,
        background: [...list.map((e) => const OnBoardingPageBackground())],
        pageBodies: [...list],
        onFinish: () {
          const HomeRoute().replace(context);
          // context.go(HomeView.routeName);
        },
        finishButtonText: "使用を開始する",
        finishButtonStyle: const FinishButtonStyle(
            hoverColor: Colors.blue,
            focusColor: Colors.blue,
            splashColor: Colors.blue,
            backgroundColor: Colors.blue),
        indicatorPosition: 20,
        indicatorAbove: true,
        hasSkip: true,
        skipTextButton: const Text(
          "skip",
          style: TextStyle(color: Colors.white),
        ),
      );
    });
  }
}
