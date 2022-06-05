import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  Widget? child;
  double? marginEdgeInsets;
  double? paddingEdgetInsets;
  CardWidget({this.child, this.marginEdgeInsets, this.paddingEdgetInsets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      margin: EdgeInsets.all(marginEdgeInsets ?? 10),
      padding: EdgeInsets.all(paddingEdgetInsets ?? 10),
      child: child,
    );
  }
}
