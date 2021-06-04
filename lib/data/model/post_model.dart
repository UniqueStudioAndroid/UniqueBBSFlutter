import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unique_bbs/config/constant.dart';
import 'package:unique_bbs/data/bean/forum/post_data.dart';
import 'package:unique_bbs/data/bean/forum/post_list.dart';
import 'package:unique_bbs/data/bean/forum/thread_info.dart';
import 'package:unique_bbs/data/bean/other/attach_data.dart';
import 'package:unique_bbs/data/repo.dart';
import 'package:unique_bbs/tool/logger.dart';

import '../dio.dart';

/// 管理某个 thread 下所有 post 信息
/// 目前每次重新启动 app 会重新拉取
/// 此 model 的生命周期和创建它的 widget 相同, 不常驻内存
/// Warning: 如果在浏览过程中出现 post 的删除或者添加, 可能会导致并发异常。目前暂不处理
/// 注: post 如果被删除的话，active 会被置 null，另外，后端下发的某些帖子 threadInfo 里的 count
/// 和实际大小不一定对应，甚至还有一些和旧接口不太兼容的东西......
/// TODO: 后续添加数据库层缓存 & 处理浏览帖子的时候帖子被删除的情况
class PostModel extends ChangeNotifier {
  static const _TAG = "PostModel";
  static const _attachType = "attach";
  ThreadInfo _threadInfo;
  PostData? _firstPost;
  List<AttachData> _attachArr = [];
  List<PostData> _postData = [];

  bool _fetching = false;
  int _fetchedPage = 0;
  bool _killed = false;
  bool _fetchComplete = false;

  Set<String> _attachFetchingSet = HashSet(); // attach id 对应的文件是否正在拉取

  PostModel(this._threadInfo);

  // 目前 post model 里面存在多少个 post 信息
  int postCount() {
    return _postData.length;
  }

  PostData? getFirstPost() {
    if (_fetchedPage == 0) {
      _fetch();
    }
    return _firstPost;
  }

  List<AttachData> getAllAttach() {
    if (_fetchedPage == 0) {
      _fetch();
    }
    return _attachArr;
  }

  // 第几个 item(从零开始计)
  // "我的"帖子信息不要调用此接口!
  PostData? getPostData(int index) {
    // 拉取超过范围，正常情况下不会出现
    if (index >= _postData.length) return null;
    // 拿最后一个并且还能拉取，则拉取下一页
    if (index == _postData.length - 1 && !_fetchComplete) {
      _fetch();
    }
    return _postData[index];
  }

  File? getAttachData(String aid) {
    var attaches = getAllAttach();
    if (_attachFetchingSet.contains(aid)) return null;

    for (AttachData attach in attaches) {
      if (attach.aid == aid) {
        final savePath = Repo.instance.getPath(_attachType, aid);
        final file = File(savePath);
        if (file.existsSync()) return file;
        _attachFetchingSet.add(aid);
        Server.instance.attachDownload(aid, savePath).then((rsp) {
          _attachFetchingSet.remove(aid);
          if (_killed) return;
          notifyListeners();
        });
      }
    }
    return null;
  }

  bool canPost() {
    return _threadInfo.active && !_threadInfo.closed;
  }

  void sendPost(String msg, String quote) {
    if (msg.isEmpty || !canPost()) {
      Fluttertoast.showToast(msg: StringConstant.sendPostFail);
      return;
    }
    Server.instance.threadReply(_threadInfo.tid, msg, quote).then((rsp) {
      Fluttertoast.showToast(
          msg: rsp.success
              ? StringConstant.sendPostSuccess
              : '${StringConstant.sendPostError}${rsp.msg}');
      _reset();
    });
  }

  void _reset() {
    _fetching = false;
    _fetchComplete = false;
    _fetchedPage = 0;

    _postData = [];
    _attachArr = [];
    _firstPost = null;
    notifyListeners();
  }

  void _fetch() async {
    if (_fetching || _killed || _fetchComplete) return;
    _fetching = true;
    // 拉取下一页
    Logger.v(_TAG, 'fetching page ${_fetchedPage + 1}');
    Server.instance
        .postsInThread(_threadInfo.tid, _fetchedPage + 1)
        .then((rsp) {
      if (rsp.success) {
        if (!_fetching) {
          return;
        }
        _fetchedPage++;
        _fetching = false;
        PostList data = rsp.data as PostList;
        // 此处 group 传的是空值，可能会有影响
        _firstPost = PostData(data.firstPost, data.threadAuthor, [], null);
        _attachArr = data.attachArr;
        _postData.addAll(data.postArr);
        if (data.postArr.length < HyperParam.pageSize) {
          _fetchComplete = true;
        }
        notifyListeners();
      } else {
        Future.delayed(Duration(seconds: HyperParam.requestInterval))
            .then((_) => _fetch());
      }
    });
  }

  // 防止页面丢失后还在不断尝试拉取
  @override
  void dispose() {
    super.dispose();
    _killed = true;
  }
}
