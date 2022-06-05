import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoWidget extends StatelessWidget {
  final String url;

  FullPhotoWidget({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
