import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tree/src/util/app_const.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';

// これらのProviderはMemoNotifierに統合されました
// final memoTextEditcontrollerProvider = ...
// final dividerHeightkeyProvider = ...

class MemoLineView extends ConsumerStatefulWidget {
  const MemoLineView({
    super.key,
    required this.oneIndent,
    required this.memoLineState,
    required this.focusNode,
  });
  final FocusNode focusNode;
  final double oneIndent;
  final MemoLineState memoLineState;

  @override
  ConsumerState<MemoLineView> createState() => _MemoLineViewState();
}

class _MemoLineViewState extends ConsumerState<MemoLineView> {
  double textFieldHeight = 0.0;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = ref
        .read(memoProvider.notifier)
        .getTextController(widget.memoLineState.index);
    widget.focusNode.addListener(_handleFocusChange);
    setTextFieldHeight();
  }

  @override
  void didUpdateWidget(covariant MemoLineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.text != widget.memoLineState.text) {
      controller.text = widget.memoLineState.text;
    }
    setTextFieldHeight();
  }

  void setTextFieldHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = ref
          .read(memoProvider.notifier)
          .getDividerKey(widget.memoLineState.index);
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          textFieldHeight = renderBox.size.height;
        });
      }
    });
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {}); // フォーカス変化時に再描画
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(memoProvider);
    const leftIconSize = 48.0;
    const dividerWidth = 1.0;
    const leadingMarginEditText = 10.0;
    final textFieldWidth = AppUtils.sWidth -
        widget.memoLineState.indent * widget.oneIndent -
        leftIconSize -
        dividerWidth -
        leadingMarginEditText;

    final key = ref
        .read(memoProvider.notifier)
        .getDividerKey(widget.memoLineState.index);
    final dividerMarginHeight = 40.0;
    return Visibility(
      visible: state.visibleList
          .map((v) => v.index)
          .contains(widget.memoLineState.index),
      child: ColoredBox(
        color: widget.focusNode.hasFocus
            ? Theme.of(context).highlightColor
            : Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: AppUtils.sWidth,
          child: Row(children: [
            InkWell(
              onTap: () {
                ref
                    .read(memoProvider.notifier)
                    .toggleFoldingStatus(widget.memoLineState.index)();
                // primaryFocus?.unfocus();
              },
              child: Row(children: [
                SizedBox(
                  width: leftIconSize,
                  height: leftIconSize,
                  child: Icon(
                    widget.memoLineState.isFolding
                        ? FontAwesomeIcons.angleRight
                        : FontAwesomeIcons.angleDown,
                  ),
                ),
              ]),
            ),
            GestureDetector(
              onHorizontalDragEnd: (ded) {
                ref
                    .read(memoProvider.notifier)
                    .onHorizontalSwiped(widget.memoLineState.index)(ded);
              },
              child: SizedBox(
                width: AppUtils.sWidth - leftIconSize,
                child: Column(
                  children: [
                    Row(children: [
                      AnimatedContainer(
                        duration: AppConst.animateDuration,
                        width: widget.memoLineState.indent * widget.oneIndent,
                      ),
                      AnimatedContainer(
                        duration: AppConst.animateDuration,
                        color: Theme.of(context).dividerColor,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              width: dividerWidth,
                              height: textFieldHeight > 0 ||
                                      constraints.maxHeight < textFieldHeight
                                  ? textFieldHeight - dividerMarginHeight
                                  : 0.0,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: leadingMarginEditText,
                      ),
                      AnimatedContainer(
                        duration: AppConst.animateDuration,
                        alignment: Alignment.centerRight,
                        width: textFieldWidth,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            cursorColor: Colors.blueAccent,
                            selectionColor:
                                Colors.blueAccent.withValues(alpha: .3),
                            selectionHandleColor: Colors.blueAccent,
                          ),
                          child: TextField(
                            key: key,
                            autofocus: false,
                            focusNode: widget.focusNode,
                            cursorColor: Colors.blueAccent,
                            maxLines: null,
                            controller: controller,
                            readOnly: widget.memoLineState.isReadOnly,
                            onTap: () async {
                              if (state.focusedIndex !=
                                  widget.memoLineState.index) {
                                ref
                                    .read(memoProvider.notifier)
                                    .resetFocusIfFocus();
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                ref
                                    .read(memoProvider.notifier)
                                    .changeFocusNodeIndex(
                                        widget.memoLineState.index);
                                widget.focusNode.requestFocus();
                              }
                            },
                            onSubmitted: (os) {
                              ref.read(memoProvider.notifier).onTextChangeEnd();
                            },
                            onTapOutside: (oto) {
                              ref.read(memoProvider.notifier).onTextChangeEnd();
                            },
                            onChanged: (text) {
                              ref.read(memoProvider.notifier).onTextChange(
                                  widget.memoLineState.index)(text);
                              // 高さを再取得して更新
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final renderBox = key.currentContext
                                    ?.findRenderObject() as RenderBox?;
                                if (renderBox != null && mounted) {
                                  setState(
                                    () {
                                      textFieldHeight = renderBox.size.height;
                                    },
                                  );
                                }
                              });
                            },
                            style: TextStyle(
                                fontSize: widget.memoLineState.fontSize,
                                color: widget.memoLineState.isReadOnly
                                    ? Theme.of(context).disabledColor
                                    : null),
                            // onTapOutside:
                            //     mSN.onTapOutside(memoLineState.index),
                            onEditingComplete: () {
                              ref.read(memoProvider.notifier).resetState();
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).disabledColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                ),
                              ),
                              focusColor: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
