import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tree/gen/assets.gen.dart';
import 'package:tree/src/util/app_const.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';

class MemoTopBarItem extends ConsumerWidget {
  const MemoTopBarItem({super.key, required this.memoLineState});
  final MemoLineState memoLineState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var index = ref.read(memoProvider).focusedIndex;
    return Material(
      child: Container(
        width: AppUtils.sWidth(),
        height: AppUtils.sHeight() / AppConst.topBarHeightRatio,
        color: Color.fromARGB(127, 0, 0, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              IconButton(
                onPressed: () {
                  final index = ref.read(memoProvider).focusedIndex;
                  if (index == -1) {
                    ref.read(memoProvider.notifier).addLineToLast();
                  } else {
                    ref.read(memoProvider.notifier).addLineToNext(index);
                  }
                },
                icon: const Icon(
                  size: 25,
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                ),
              ),
              AnimatedContainer(
                duration: AppConst.animateDuration,
                child: index == -1
                    ? Container()
                    : Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(memoProvider.notifier)
                                  .resetFocusIfFocus();
                              ref.read(memoProvider.notifier).resetState();
                            },
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SvgPicture.asset(
                                Assets.images.unfocus,
                                width: 25,
                                height: 25,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              AnimatedContainer(
                duration: AppConst.animateDuration,
                child: index == -1
                    ? Container()
                    : Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            onPressed: () {
                              if (index >= 0) {
                                ref
                                    .read(memoProvider.notifier)
                                    .onChangeIndent(index, -1)();
                              }
                            },
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SvgPicture.asset(
                                Assets.images.decreaseIndent,
                                width: 25,
                                height: 25,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            onPressed: () {
                              if (index >= 0) {
                                ref
                                    .read(memoProvider.notifier)
                                    .onChangeIndent(index, 1)();
                              }
                            },
                            icon: SvgPicture.asset(
                              Assets.images.increaseIndent,
                              width: 25,
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          memoLineState.isReadOnly
                              ? IconButton(
                                  onPressed: () {
                                    if (index >= 0) {
                                      ref
                                          .read(memoProvider.notifier)
                                          .toggleReadOnlyStatus(index)();
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    Assets.images.lockUnlocked,
                                    width: 25,
                                    height: 25,
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    if (index >= 0) {
                                      ref
                                          .read(memoProvider.notifier)
                                          .toggleReadOnlyStatus(index)();
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    Assets.images.lockLocked,
                                    width: 22,
                                    height: 22,
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(memoProvider.notifier)
                                  .showSliderFontSizeChangeDialog();
                            },
                            icon: SvgPicture.asset(
                              Assets.images.changeFontSize,
                              width: 25,
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(memoProvider.notifier)
                      .showSliderIndentChangeDialog();
                },
                icon: SvgPicture.asset(
                  Assets.images.changeIndentWidth,
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                onPressed: ref.read(memoProvider.notifier).showClearDialogs,
                icon: SvgPicture.asset(
                  Assets.images.erase,
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                onPressed: () {
                  ref.read(memoProvider.notifier).showSaveDialog(() {});
                },
                icon: SvgPicture.asset(
                  Assets.images.save,
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              AnimatedContainer(
                duration: AppConst.animateDuration,
                child: index == -1
                    ? Container()
                    : Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            onPressed: () {
                              if (index >= 0) {
                                ref
                                    .read(memoProvider.notifier)
                                    .showAlertDeleteLine(index);
                              }
                            },
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SvgPicture.asset(
                                Assets.images.cancel,
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                    Colors.redAccent, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
