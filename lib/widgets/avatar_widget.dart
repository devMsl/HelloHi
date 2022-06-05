import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  String? imgUrl;
  double size;

  AvatarWidget({this.imgUrl, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: CachedNetworkImage(
          maxHeightDiskCache: 400,
          maxWidthDiskCache: 400,
          fit: BoxFit.cover,
          imageUrl: imgUrl ?? '',
          errorWidget: (context, string, _) {
            return Container(
              color: Colors.grey,
            );
          },
          placeholder: (context, string) {
            return Container(
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }
}
