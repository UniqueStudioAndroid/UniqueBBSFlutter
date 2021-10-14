import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unique_bbs/config/constant.dart';
import 'package:unique_bbs/config/route.dart';
import 'package:unique_bbs/data/bean/user/user.dart';
import 'package:unique_bbs/data/bean/user/user_info.dart';
import 'package:unique_bbs/data/model/user_model.dart';
import 'package:unique_bbs/data/repo.dart';
import 'package:unique_bbs/widget/common/common_avatar.dart';

/// 点击头像后显示详情页面

// 底部留出空间
const _bottomOffset = 50.0;
// 整体
const _mainHorizontalPadding = 15.0;
// 通知
const _notificationHeight = 90.0;
// 头像部分
const _portraitRadius = 35.5;
// 名字部分
const _nameTextStyle = TextStyle(
  fontSize: 17,
  color: ColorConstant.textLightBlack,
  fontWeight: FontWeight.bold,
  letterSpacing: 1,
);
// 活跃积分
const _activePointTextStyle = TextStyle(
  fontSize: 12,
  color: ColorConstant.textGrey,
  fontWeight: FontWeight.bold,
);
const _activePointNumStyle = TextStyle(
  fontSize: 12,
  color: ColorConstant.primaryColor,
  fontWeight: FontWeight.bold,
);
// 标识卡片部分
const _cardRadius = 25.0;
const _cardTextVerticalPadding = 4.0;
const _cardTextHorizontalPadding = 10.0;
const _cardTextStyle = TextStyle(fontSize: 10, color: ColorConstant.textWhite);
// 中间信息部分
const _iconSize = 20.0;
const _iconTextOffset = 10.0;
const _personalVerticalPadding = 14.0;
const _maxSignLine = 10;
final _divider = Container(
  height: 0.2,
  margin: EdgeInsets.symmetric(vertical: 8.0),
  color: ColorConstant.backgroundGrey,
);
const _signatureTextStyle = TextStyle(
  color: ColorConstant.textBlack,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
const _personalTextStyle = TextStyle(
  color: ColorConstant.textBlack,
  fontSize: 13,
  fontWeight: FontWeight.bold,
);
const _personalDataTextStyle = TextStyle(
  color: ColorConstant.textGrey,
  fontSize: 12,
);

// 底部几个按钮部分
const _buttonTextPadding = 10.0;
const _buttonTextHorizontalPadding = 20.0;
const _buttonRadius = 25.0;
const _buttonTextFontSize = 15.0;
const _buttonTextSpacing = 2.0;
final _buttonRoundedBorder =
RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius));

Widget _buildHeadPortrait(UserInfo? user) {
  return BBSAvatar(
    url: user?.avatar,
    radius: _portraitRadius,
  );
}

Widget _buildName(UserInfo? user) {
  final name = user == null ? StringConstant.noData : user.username;
  return Container(
    alignment: Alignment.center,
    child: Text(
      name,
      style: _nameTextStyle,
    ),
  );
}

Widget _buildActivePoint() {
  return Container(
    alignment: Alignment.center,
    child: Text.rich(TextSpan(
      children: [
        TextSpan(
            text: StringConstant.activePoint, style: _activePointTextStyle),
        TextSpan(text: ': 0', style: _activePointNumStyle),
      ],
    )),
  );
}


Widget _wrapBoxShadow(Widget child, double verticalPadding) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: _buttonTextHorizontalPadding),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(_buttonRadius),
      border: Border.all(color: ColorConstant.borderLightPink),
      color: ColorConstant.backgroundWhite,
    ),
    child: child,
  );
}

Widget _buildSignature(UserInfo? user, bool isOpen, VoidCallback callback) {
  final signature = user == null ? StringConstant.noData : user.signature;
  final widget = Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${StringConstant.signature}   ',
        style: _signatureTextStyle,
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            signature,
            style: _personalDataTextStyle,
            maxLines: isOpen ? _maxSignLine : 1,
          ),
        ),
        flex: 1,
      ),
      Container(
        child: GestureDetector(
          onTap: callback,
          child: isOpen
              ? Icon(Icons.keyboard_arrow_up)
              : Icon(Icons.keyboard_arrow_down),
        ),
      ),
    ],
  );
  return _wrapBoxShadow(widget, _buttonTextPadding);
}

Widget _wrapPersonalDataLine(String iconSrc, String type, String data) {
  // 每一行第一个数据是 Icon 名字, 第二个是提示信息, 第三个是实际数据
  return Container(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _iconSize,
          height: _iconSize,
          alignment: Alignment.center,
          margin: EdgeInsets.only(right: _iconTextOffset),
          child: SvgPicture.asset(iconSrc),
        ),
        Text(
          type,
          style: _personalTextStyle,
        ),
        Expanded(
          child: Text(
            data,
            textAlign: TextAlign.end,
            style: _personalDataTextStyle,
          ),
          flex: 1,
        ),
      ],
    ),
  );
}

Widget _buildPersonalData(UserInfo? user) {
  // 这里将构建一行 UI 所需要的字符串都封装在一起, 后面直接传递给 _wrapPersonalDataLine
  final mobile = user == null ? StringConstant.noData : user.mobile;
  final weChat = user == null ? StringConstant.noData : user.wechat;
  final email = user == null ? StringConstant.noData : user.email;
  return _wrapBoxShadow(
    Column(
      children: [
        _wrapPersonalDataLine(
            SvgIcon.phoneNumber, StringConstant.phoneNumber, mobile),
        _divider,
        _wrapPersonalDataLine(SvgIcon.weChat, StringConstant.weChat, weChat),
        _divider,
        _wrapPersonalDataLine(SvgIcon.mailbox, StringConstant.mailbox, email),
      ],
    ),
    _personalVerticalPadding,
  );
}

Widget _buildShowUserPost(BuildContext context, UserInfo? user) {
  return FlatButton(
    minWidth: double.infinity,
    onPressed: () {
      if (user != null) {
        Navigator.of(context).pushNamed(BBSRoute.userPosts, arguments: user);
      }
    },
    shape: _buttonRoundedBorder,
    color: ColorConstant.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: _buttonTextPadding),
    child: Text(
      StringConstant.showUserPost,
      style: const TextStyle(
        fontSize: _buttonTextFontSize,
        color: ColorConstant.textWhite,
        letterSpacing: _buttonTextSpacing,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildShowUserReport(BuildContext context, UserInfo? user) {
  return FlatButton(
    minWidth: double.infinity,
    onPressed: () {
      if (user != null) {
        Navigator.of(context).pushNamed(BBSRoute.userReports, arguments: user);
      }
    },
    shape: _buttonRoundedBorder,
    color: ColorConstant.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: _buttonTextPadding),
    child: Text(
      StringConstant.showUserReport,
      style: const TextStyle(
        fontSize: _buttonTextFontSize,
        color: ColorConstant.textWhite,
        letterSpacing: _buttonTextSpacing,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class UserDetailWidget extends StatefulWidget {
  final UserInfo user;

  UserDetailWidget(this.user);

  @override
  State createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetailWidget> {
  bool _isSignOpen = false; // 是否展开签名

  @override
  Widget build(BuildContext context) {
    final signOpenCallback = () =>
        setState(() {
          _isSignOpen = !_isSignOpen;
        });
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        UserInfo? user = widget.user;
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios),
            ),
            backgroundColor: ColorConstant.backgroundLightGrey,
            centerTitle: true,
          ),
          body: Column(
              children: [
                //_buildNotification(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _mainHorizontalPadding),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(height: 10),
                        _buildHeadPortrait(user),
                        Container(height: 8),
                        _buildName(user),
                        _buildActivePoint(),
                        Container(height: 10),
                        Container(height: 23),
                        _buildSignature(user, _isSignOpen, signOpenCallback),
                        Container(height: 11),
                        _buildPersonalData(user),
                        Container(height: 30),
                        _buildShowUserPost(context, user),
                        Container(height: 10),
                        _buildShowUserReport(context, user),
                        Container(height: _bottomOffset),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
              ],
          ),
        );
      },
    );
  }
}

