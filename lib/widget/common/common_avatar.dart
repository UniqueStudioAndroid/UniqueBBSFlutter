import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:unique_bbs/config/constant.dart';
import 'package:unique_bbs/data/model/avatar_model.dart';

class BBSAvatar extends StatelessWidget {
  final String? url;
  final double radius;

  BBSAvatar({this.url, this.radius = 25.0});

  @override
  Widget build(BuildContext context) {
    return Consumer<AvatarModel>(
        builder: (context, model, child) {
          Widget? child;
          final path = url;
          if (path == null ||
              path.isEmpty ||
              (child = model.find(path)) == null) {
            child = SvgPicture.asset(
              SvgIcon.defaultAvatar,
              height: radius * 2,
              width: radius * 2,
            );
          }
          return Container(
            height: radius * 2,
            width: radius * 2,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: child,
          );
        },
      );
  }
}
