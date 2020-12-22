import 'package:UniqueBBSFlutter/config/constant.dart';
import 'package:UniqueBBSFlutter/data/model/avatar_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class BBSAvatar extends StatelessWidget {
  final String url;
  final double radius;

  BBSAvatar(this.url, {this.radius = 25.0});

  @override
  Widget build(BuildContext context) {
    return Consumer<AvatarModel>(
      builder: (context, model, child) {
        Widget child;
        if (url == null || (child = model.find(url)) == null) {
          child = SvgPicture.asset(SvgIcon.defaultAvatar);
        }
        return Container(
          width: radius * 2,
          height: radius * 2,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: child,
        );
      },
    );
  }
}