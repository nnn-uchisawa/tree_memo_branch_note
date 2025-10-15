// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/cancel.svg
  String get cancel => 'assets/images/cancel.svg';

  /// File path: assets/images/change-font-size.svg
  String get changeFontSize => 'assets/images/change-font-size.svg';

  /// File path: assets/images/change-indent-width.svg
  String get changeIndentWidth => 'assets/images/change-indent-width.svg';

  /// File path: assets/images/check.svg
  String get check => 'assets/images/check.svg';

  /// File path: assets/images/decrease-indent.svg
  String get decreaseIndent => 'assets/images/decrease-indent.svg';

  /// File path: assets/images/erase.svg
  String get erase => 'assets/images/erase.svg';

  /// File path: assets/images/focus.svg
  String get focus => 'assets/images/focus.svg';

  /// File path: assets/images/folder.svg
  String get folder => 'assets/images/folder.svg';

  /// File path: assets/images/function.svg
  String get function => 'assets/images/function.svg';

  /// File path: assets/images/increase-indent.svg
  String get increaseIndent => 'assets/images/increase-indent.svg';

  /// File path: assets/images/line-down.svg
  String get lineDown => 'assets/images/line-down.svg';

  /// File path: assets/images/line-up.svg
  String get lineUp => 'assets/images/line-up.svg';

  /// File path: assets/images/lock-locked.svg
  String get lockLocked => 'assets/images/lock-locked.svg';

  /// File path: assets/images/lock-unlocked.svg
  String get lockUnlocked => 'assets/images/lock-unlocked.svg';

  /// File path: assets/images/open-folder.svg
  String get openFolder => 'assets/images/open-folder.svg';

  /// File path: assets/images/profile.png
  AssetGenImage get profile => const AssetGenImage('assets/images/profile.png');

  /// File path: assets/images/read-only.svg
  String get readOnly => 'assets/images/read-only.svg';

  /// File path: assets/images/save.svg
  String get save => 'assets/images/save.svg';

  /// File path: assets/images/share.svg
  String get share => 'assets/images/share.svg';

  /// Directory path: assets/images/tutorial
  $AssetsImagesTutorialGen get tutorial => const $AssetsImagesTutorialGen();

  /// File path: assets/images/unfocus.svg
  String get unfocus => 'assets/images/unfocus.svg';

  /// File path: assets/images/vertical-three.svg
  String get verticalThree => 'assets/images/vertical-three.svg';

  /// List of all assets
  List<dynamic> get values => [
    cancel,
    changeFontSize,
    changeIndentWidth,
    check,
    decreaseIndent,
    erase,
    focus,
    folder,
    function,
    increaseIndent,
    lineDown,
    lineUp,
    lockLocked,
    lockUnlocked,
    openFolder,
    profile,
    readOnly,
    save,
    share,
    unfocus,
    verticalThree,
  ];
}

class $AssetsImagesTutorialGen {
  const $AssetsImagesTutorialGen();

  /// File path: assets/images/tutorial/1.png
  AssetGenImage get a1 => const AssetGenImage('assets/images/tutorial/1.png');

  /// File path: assets/images/tutorial/2.png
  AssetGenImage get a2 => const AssetGenImage('assets/images/tutorial/2.png');

  /// File path: assets/images/tutorial/3.png
  AssetGenImage get a3 => const AssetGenImage('assets/images/tutorial/3.png');

  /// File path: assets/images/tutorial/4.PNG
  AssetGenImage get a4 => const AssetGenImage('assets/images/tutorial/4.PNG');

  /// List of all assets
  List<AssetGenImage> get values => [a1, a2, a3, a4];
}

class Assets {
  const Assets._();

  static const String tree = 'assets/Treeの使い方.tmson';
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const String a = 'assets/クラウド機能の使い方.tmson';

  /// List of all assets
  static List<String> get values => [tree, a];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
