import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pwviewer/models/notification_type.dart';
import 'package:pwviewer/status_details/status_details.dart';
import 'package:pwviewer/user_details/user_details.dart';
import 'package:pwviewer/utils/maybe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:pwviewer/models/notification.dart' as model;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _authorized = true; // falseだと認証済みでも一瞬ログイン要求が表示される
  bool _nextPageExists = true; // まず存在すると仮定
  Maybe<List<model.Notification>> _notifications = Maybe.nothing();
  Maybe<String> _nextPageUrl = Maybe.nothing();

  Widget _buildLoginHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 8.0,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Flexible(
                    flex: 0,
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                  ),
                  Flexible(flex: 0, child: Container(width: 16)),
                  Flexible(
                    flex: 1,
                    child: Text('通知一覧を表示するには認証が必要です\n設定画面から認証キーを設定してください'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, model.Notification notification) {
    final icon = notification.type == NotificationType.follow
        ? Icons.person_add
        : notification.type == NotificationType.follow_request
            ? Icons.pending
            : notification.type == NotificationType.favourite
                ? Icons.favorite_outline
                : notification.type == NotificationType.mention
                    ? Icons.alternate_email
                    : notification.type == NotificationType.reblog
                        ? Icons.repeat
                        : notification.type == NotificationType.poll
                            ? Icons.list
                            : notification.type == NotificationType.status
                                ? Icons.post_add
                                : Icons.help_outline;

    final performedBy = notification.account.displayNameOrUserName;
    final title = notification.type == NotificationType.follow
        ? '$performedBy さんにフォローされました'
        : notification.type == NotificationType.follow_request
            ? '$performedBy さんがフォローをリクエストしています'
            : notification.type == NotificationType.favourite
                ? '$performedBy さんがお気に入りしました'
                : notification.type == NotificationType.mention
                    ? '$performedBy さんにメンションされました'
                    : notification.type == NotificationType.reblog
                        ? '$performedBy さんがブーストしました'
                        : notification.type == NotificationType.poll
                            ? '$performedBy さんのアンケートが終了しました'
                            : notification.type == NotificationType.status
                                ? '$performedBy さんが投稿しました'
                                : '未知の通知';
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        switch (notification.type) {
          case NotificationType.follow:
          case NotificationType.follow_request:
            final args = UserDetailsArguments(notification.account.id);
            Navigator.pushNamed(context, UserDetails.routeName,
                arguments: args);
            break;
          case NotificationType.favourite:
          case NotificationType.mention:
          case NotificationType.reblog:
          case NotificationType.poll:
          case NotificationType.status:
            final args = StatusDetailsArguments(notification.status!.id);
            Navigator.pushNamed(context, StatusDetails.routeName,
                arguments: args);
            break;
        }
      },
    );
  }

  Widget _buildNotifications(BuildContext context) {
    if (_notifications.isNothing()) {
      return _buildLoader(context);
    } else {
      if (_notifications.unwrap().isEmpty) {
        return Center(
          child: Text('通知なし'),
        );
      } else {
        return ListView.separated(
          itemBuilder: (ctx, idx) {
            if (idx == _notifications.unwrap().length) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _buildNotificationTile(
                  context, _notifications.unwrap()[idx]);
            }
          },
          separatorBuilder: (ctx, idx) => Divider(),
          itemCount: _notifications.unwrap().length + (_nextPageExists ? 1 : 0),
        );
      }
    }
  }

  Future _retrieveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    // This method must be called after authorization check
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY)!;
    final uri = Uri.parse(_nextPageUrl.unwrapOrNull() ?? getNotificationsUrl());
    final res = await http.get(uri, headers: {
      REQUEST_HEADER_AUTHORIZATION:
          REQUEST_HEADER_AUTHORIZATION_PREFIX + authKey
    });

    if (res.statusCode == 200) {
      final notifications = jsonDecode(res.body)
          .map((v) => model.Notification.fromJson(v))
          .cast<model.Notification>()
          .toList();
      var nextUrl = res.headers['link']?.split(';').last;
      nextUrl = nextUrl?.substring(1, nextUrl.length - 1);

      setState(() {
        _notifications = Maybe.some(notifications);
        _nextPageUrl = Maybe.some(nextUrl);
        _nextPageExists = nextUrl != null;
      });
    }
  }

  Future _checkAuthorized() async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY);

    setState(() {
      _authorized = authKey != null;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await _checkAuthorized();

      if (_authorized) {
        await _retrieveNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_authorized
        ? _buildLoginHint(context)
        : _buildNotifications(context);
  }
}
