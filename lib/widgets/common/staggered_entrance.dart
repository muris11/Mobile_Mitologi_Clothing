import 'package:flutter/material.dart';

class SliverStaggeredEntrance extends StatelessWidget {
  final int itemCount;
  final int delayMillis;
  final Widget Function(BuildContext, int) itemBuilder;

  const SliverStaggeredEntrance({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.delayMillis = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => itemBuilder(context, index),
        childCount: itemCount,
      ),
    );
  }
}
