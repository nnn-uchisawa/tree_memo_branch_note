// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:tree_memo/gen/assets.gen.dart';
// import 'package:tree_memo/src/view/pages/memo/memo_line_state.dart';
// import 'package:tree_memo/src/view/pages/memo/memo_state_notifier.dart';

// class MemoLineFunctions extends ConsumerWidget {
//   const MemoLineFunctions({super.key, required this.memoLineState});

//   final MemoLineState memoLineState;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       // width: 230,
//       decoration: const BoxDecoration(
//         color: Color.fromARGB(192, 200, 200, 200),
//         borderRadius: BorderRadius.all(
//           Radius.circular(10),
//         ),
//       ),
//       child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             InkWell(
//               onTap: ref
//                   .read(memoStateProvider.notifier)
//                   .onChangeIndent(memoLineState.index, -1),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 5),
//                 child: SvgPicture.asset(
//                   Assets.images.decreaseIndent,
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//             ),
//             InkWell(
//               onTap: ref
//                   .read(memoStateProvider.notifier)
//                   .onChangeIndent(memoLineState.index, 1),
//               child: SvgPicture.asset(
//                 Assets.images.increaseIndent,
//                 width: 30,
//                 height: 30,
//               ),
//             ),
//             memoLineState.isReadOnly
//                 ? InkWell(
//                     onTap: ref
//                         .read(memoStateProvider.notifier)
//                         .toggleReadOnlyStatus(memoLineState.index),
//                     child: SvgPicture.asset(
//                       Assets.images.lockUnlocked,
//                       width: 30,
//                       height: 30,
//                     ),
//                   )
//                 : InkWell(
//                     onTap: ref
//                         .read(memoStateProvider.notifier)
//                         .toggleReadOnlyStatus(memoLineState.index),
//                     child: SvgPicture.asset(
//                       Assets.images.lockLocked,
//                       width: 25,
//                       height: 25,
//                     ),
//                   ),
//             Container(
//               color: Colors.black,
//               width: 1,
//               height: 35,
//             ),
//             Row(
//               children: [
//                 InkWell(
//                   onTap: () {},
//                   child: SvgPicture.asset(
//                     Assets.images.changeFontSize,
//                     width: 30,
//                     height: 30,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 100,
//                   child: Slider(
//                     min: 6,
//                     max: 30,
//                     value: memoLineState.fontSize,
//                     onChanged: (v) {
//                       ref
//                           .read(memoStateProvider.notifier)
//                           .onChangeFontSize(memoLineState.index, v);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             Container(
//               color: Colors.black,
//               width: 1,
//               height: 35,
//             ),
//             // InkWell(
//             //   onTap: ref
//             //       .read(memoStateProvider.notifier)
//             //       .deleteLine(memoLineState.index),
//             //   child: Padding(
//             //     padding: const EdgeInsets.only(left: 5),
//             //     child: SvgPicture.asset(
//             //       Assets.images.cancel,
//             //       width: 20,
//             //       height: 20,
//             //       color: Colors.redAccent,
//             //     ),
//             //   ),
//             // ),
//             const SizedBox(
//               width: 8,
//             )
//           ]),
//     );
//   }
// }
