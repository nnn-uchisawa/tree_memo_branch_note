import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/src/libraries/on_boarding_slider/page_offset_provider.dart';

class BackgroundImage extends StatelessWidget {
  final int id;
  final Widget background;
  final double imageVerticalOffset;
  final double speed;
  final double imageHorizontalOffset;
  final bool centerBackground;

  const BackgroundImage({
    super.key,
    required this.id,
    required this.speed,
    required this.background,
    required this.imageVerticalOffset,
    required this.centerBackground,
    required this.imageHorizontalOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Stack(children: [
          Positioned(
            top: imageVerticalOffset,
            left: MediaQuery.of(context).size.width * ((id - 1) * speed) -
                speed * notifier.offset +
                (centerBackground ? 0 : imageHorizontalOffset),
            child: centerBackground
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: child!,
                  )
                : child!,
          ),
        ]);
      },
      child: Container(
        child: background,
      ),
    );
  }
}
