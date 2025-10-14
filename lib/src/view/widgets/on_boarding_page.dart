import 'package:flutter/material.dart';
import 'package:tree/src/util/app_utils.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, this.image, this.title, this.description});

  final Image? image;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container(),
          const SizedBox(
            height: 50,
          ),
          image ?? Container(),
          const SizedBox(
            height: 50,
          ),
          description != null
              ? Text(
                  description!,
                  style: const TextStyle(color: Colors.white),
                )
              : Container(),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}

class OnBoardingPageBackground extends StatelessWidget {
  const OnBoardingPageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: AppUtils.sWidth,
      height: AppUtils.sHeight,
    );
  }
}
