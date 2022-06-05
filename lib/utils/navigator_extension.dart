import 'package:flutter/material.dart';

extension NavigatorExtension on BuildContext {
  Future<T?> pushed<T extends Object>(Widget widget) async {
    return await Navigator.of(this).push(MaterialPageRoute(builder: (context) {
      return widget;
    }));
  }

  void backed<T extends Object>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}
