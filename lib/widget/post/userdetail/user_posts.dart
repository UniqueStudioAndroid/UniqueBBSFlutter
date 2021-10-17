import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unique_bbs/config/constant.dart';
import 'package:unique_bbs/data/bean/forum/full_forum.dart';
import 'package:unique_bbs/data/bean/user/user_info.dart';
import 'package:unique_bbs/data/model/thread_model.dart';
import 'package:unique_bbs/widget/post/thread_list.dart';

const _titleTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 18,
);

class UserPostsWidget extends StatefulWidget {
  final UserInfo? user;

  UserPostsWidget(this.user);

  @override
  State<StatefulWidget> createState() => UserPostsState();
}

class UserPostsState extends State<UserPostsWidget> {
  late ThreadModel model =
  ThreadModel(null, user: widget.user);
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initScrollController();
    _fetchData();
  }

  void _initScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  _fetchData() {
    model.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => model,
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: ColorConstant.backgroundLightGrey,
          title: Text(
            StringConstant.userPost,
            style: _titleTextStyle,
          ),
          centerTitle: true,
        ),
        body: _buildBody(context),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Consumer<ThreadModel>(builder: (context, model, child) {
      return SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThreadListCard(model),
                _buildBottomText(),
              ],
            )),
      );
    });
  }

  _buildBottomText() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        StringConstant.noMoreForum,
        style: TextStyle(
            fontSize: 13,
            color: ColorConstant.textLightPurPle,
            letterSpacing: 3),
      ),
    );
  }
}