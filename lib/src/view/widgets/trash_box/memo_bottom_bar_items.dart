// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tree_memo/gen/assets.gen.dart';
// import 'package:tree_memo/src/app.dart';
// import 'package:tree_memo/src/view/pages/memo/memo_state.dart';
// import 'package:tree_memo/src/view/pages/memo/memo_state_notifier.dart';

// class MemoBottomBarItem extends HookConsumerWidget {
//   const MemoBottomBarItem({
//     super.key,
//     required this.index,
//   });

//   final int index;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     switch (index) {
//       case 0:
//         return FloatingActionButton(
//             heroTag: 'plus',
//             shape: const CircleBorder(),
//             backgroundColor: Colors.blue.shade200,
//             splashColor: Colors.grey.withOpacity(0.1),
//             elevation: 2,
//             highlightElevation: 2,
//             onPressed: ref.read(memoStateProvider.notifier).addLineToLast,
//             child: const Icon(
//               size: 30,
//               FontAwesomeIcons.plus,
//               color: Colors.white,
//             ));
//       case 1:
//         return FloatingActionButton(
//             shape: const CircleBorder(),
//             heroTag: 'back',
//             backgroundColor: Colors.blue.shade200,
//             splashColor: Colors.grey.withOpacity(0.1),
//             elevation: 2,
//             highlightElevation: 2,
//             onPressed: () {
//               var state = ref.watch(memoStateProvider);
//               state = MemoState();
//               if (navigatorKey.currentContext != null) {
//                 var context = navigatorKey.currentContext as BuildContext;
//                 context.pop();
//               }
//             },
//             child: const Icon(
//               size: 30,
//               FontAwesomeIcons.angleLeft,
//               color: Colors.white,
//             ));
//       case 2:
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             ref.read(memoStateProvider).isTapIndentChange
//                 ? SizedBox(
//                     width: 200,
//                     child: Consumer(
//                       builder: (c, r, w) {
//                         return Slider(
//                             divisions: 29,
//                             max: 30,
//                             min: 1,
//                             value: r.read(memoStateProvider).oneIndent,
//                             onChanged: (v) {
//                               r
//                                   .read(memoStateProvider.notifier)
//                                   .onChangeOneIndent(v);
//                             });
//                       },
//                     ),
//                   )
//                 : Container(),
//             FloatingActionButton(
//                 heroTag: 'indent',
//                 shape: const CircleBorder(),
//                 backgroundColor: Colors.blue.shade200,
//                 splashColor: Colors.grey.withOpacity(0.1),
//                 elevation: 2,
//                 highlightElevation: 2,
//                 onPressed: ref
//                     .read(memoStateProvider.notifier)
//                     .toggleIndentChangeStatus,
//                 child: SvgPicture.asset(
//                   Assets.images.changeIndentWidth,
//                   width: 30,
//                   height: 30,
//                   color: Colors.white,
//                 )),
//           ],
//         );
//       case 3:
//         return FloatingActionButton(
//             heroTag: 'erase',
//             shape: const CircleBorder(),
//             backgroundColor: Colors.blue.shade200,
//             splashColor: Colors.grey.withOpacity(0.1),
//             elevation: 2,
//             highlightElevation: 2,
//             onPressed: ref.read(memoStateProvider.notifier).showClearDialogs,
//             child: SvgPicture.asset(
//               Assets.images.erase,
//               width: 30,
//               height: 30,
//               color: Colors.white,
//             ));
//       case 4:
//         return FloatingActionButton(
//             heroTag: 'save',
//             shape: const CircleBorder(),
//             backgroundColor: Colors.blue.shade200,
//             splashColor: Colors.grey.withOpacity(0.1),
//             elevation: 2,
//             highlightElevation: 2,
//             onPressed: () {
//               ref.read(memoStateProvider.notifier).showSaveDialog(() {
//                 // ref.invalidate(homeStateProvider);
//                 // ref.invalidate(fileNamesFutureProvider);
//               });
//             },
//             child: SvgPicture.asset(
//               Assets.images.save,
//               width: 30,
//               height: 30,
//               color: Colors.white,
//             ));
//     }
//     return Container();
//   }
// }
