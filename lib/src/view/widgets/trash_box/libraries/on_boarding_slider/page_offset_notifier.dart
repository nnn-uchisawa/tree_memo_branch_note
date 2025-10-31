// import 'package:flutter/cupertino.dart';
// // ignore: depend_on_referenced_packages
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:tree/src/view/widgets/trash_box/libraries/on_boarding_slider/page_offset_state.dart';

// part 'page_offset_notifier.g.dart';

// @riverpod
// class PageOffsetNotifier extends _$PageOffsetNotifier {
//   late final PageController _controller;
//   late final VoidCallback _listener;

//   @override
//   PageOffsetState build(PageController controller) {
//     _controller = controller;
//     _listener = () {
//       state = state.copyWith(
//         offset: _controller.offset,
//         page: _controller.page ?? 0,
//       );
//     };
//     _controller.addListener(_listener);
//     ref.onDispose(() => _controller.removeListener(_listener));
//     return const PageOffsetState();
//   }
// }
