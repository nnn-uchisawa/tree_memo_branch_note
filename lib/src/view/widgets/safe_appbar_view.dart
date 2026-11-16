import 'package:flutter/material.dart';

class SafeAppBarView extends StatelessWidget {
  const SafeAppBarView({
    super.key,
    required this.appBar,
    required this.body,
    this.bottom,
  });

  final AppBar appBar;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomSheet: bottom,
      body: SafeArea(child: body),
    );
  }
}
