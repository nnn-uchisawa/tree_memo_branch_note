import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool obscureText;
  final String obscuringCharacter;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollController? scrollController;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final bool readOnly;

  // Decoration / Placeholder
  final InputDecoration? decoration; // Material 用
  final String? placeholder; // Cupertino 用

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPhysics,
    this.autofillHints,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scrollController,
    this.onTap,
    this.onTapOutside,
    this.readOnly = false, // デフォルト false
    this.decoration,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        autofocus: autofocus,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorColor: cursorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        selectionControls: selectionControls,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        restorationId: restorationId,
        scrollController: scrollController,
        onTap: onTap,
        readOnly: readOnly, // 👈 iOS 側でも反映
        placeholder: placeholder,
        contextMenuBuilder:
            (BuildContext ctx, EditableTextState editableTextState) {
          // editableTextState には:
          //  - contextMenuAnchors : アンカー位置 (primary/secondary)
          //  - contextMenuButtonItems : デフォルトのボタン情報 (cut/copy/paste 等)
          //
          // AdaptiveTextSelectionToolbar.getAdaptiveButtons を使うと、
          // 現在のプラットフォーム向けのボタン Widgets を作ってくれます。
          final anchors = editableTextState.contextMenuAnchors;
          final items = editableTextState.contextMenuButtonItems; // <- これを直

          // 必要であればボタンを追加・差し替えできます:
          // defaultButtons.insert(0, yourCustomButtonWidget);

          // ここでラップして枠線や背景を変更
          return Container(
            // 透明部分を残したければ color: Colors.transparent でも可
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.blue, width: 2), // ← ボーダー色をここで変更
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    blurStyle: BlurStyle.normal,
                    spreadRadius: 0)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              // AdaptiveTextSelectionToolbar.buttonItems はアンカー指定で
              // プラットフォームに応じた位置合わせをしてくれます。
              child: AdaptiveTextSelectionToolbar.buttonItems(
                anchors: anchors,
                buttonItems: items,
              ),
            ),
          );
        },
      );
    } else {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        maxLength: maxLength,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        onAppPrivateCommand: onAppPrivateCommand,
        enabled: enabled,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        scrollController: scrollController,
        onTap: onTap,
        onTapOutside: onTapOutside, // 👈 Android/Material 側のみ対応
        readOnly: readOnly, // 👈 ここも追加
        decoration: decoration ?? InputDecoration(labelText: placeholder),
        contextMenuBuilder:
            (BuildContext ctx, EditableTextState editableTextState) {
          // editableTextState には:
          //  - contextMenuAnchors : アンカー位置 (primary/secondary)
          //  - contextMenuButtonItems : デフォルトのボタン情報 (cut/copy/paste 等)
          //
          // AdaptiveTextSelectionToolbar.getAdaptiveButtons を使うと、
          // 現在のプラットフォーム向けのボタン Widgets を作ってくれます。
          final anchors = editableTextState.contextMenuAnchors;
          final items = editableTextState.contextMenuButtonItems; // <- これを直

          // 必要であればボタンを追加・差し替えできます:
          // defaultButtons.insert(0, yourCustomButtonWidget);

          // ここでラップして枠線や背景を変更
          return Container(
            // 透明部分を残したければ color: Colors.transparent でも可
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.blue, width: 2), // ← ボーダー色をここで変更
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    blurStyle: BlurStyle.normal,
                    spreadRadius: 0)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              // AdaptiveTextSelectionToolbar.buttonItems はアンカー指定で
              // プラットフォームに応じた位置合わせをしてくれます。
              child: AdaptiveTextSelectionToolbar.buttonItems(
                anchors: anchors,
                buttonItems: items,
              ),
            ),
          );
        },
      );
    }
  }
}
