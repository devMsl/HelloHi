import 'package:flutter/material.dart';

import '../widgets/theme.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          color: ThemeType.mainColor,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
