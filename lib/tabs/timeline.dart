import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/statuses_list/statuses_list.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:pwviewer/utils/maybe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Timeline extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  int _limit = 50;
  // List<Status> _statusList = [];
  Maybe<List<Status>> _statusList = Maybe.nothing();

  Future _retrieveTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY) ??
        SHARED_PREFERENCES_UNSET_AUTHORIZATION_KEY;

    if (authKey == SHARED_PREFERENCES_UNSET_AUTHORIZATION_KEY) {
      final uri = Uri.parse(getLocalTimelineUrl(_limit));
      final res = await http.get(uri);
      final statusList = jsonDecode(res.body);

      setState(() {
        _statusList = Maybe.some(statusList
            .cast<Map<String, dynamic>>()
            .map((e) => Status.fromJson(e))
            .cast<Status>()
            .toList());
      });
    } else {
      final uri = Uri.parse(getHomeTimelineUrl(_limit));
      final res = await http.get(
        uri,
        headers: {
          REQUEST_HEADER_AUTHORIZATION:
              REQUEST_HEADER_AUTHORIZATION_PREFIX + authKey,
        },
      );

      if (res.statusCode == 200) {
        final statusList = jsonDecode(res.body);
        setState(() {
          _statusList = Maybe.some(statusList
              .cast<Map<String, dynamic>>()
              .map((e) => Status.fromJson(e))
              .cast<Status>()
              .toList());
        });
      } else {
        final snackBar = SnackBar(
          content: Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Text('ホームタイムラインの取得に失敗しました'),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _retrieveTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _retrieveTimeline,
      // child: StatusesList(_statusList),
      child: _statusList.isNothing()
          ? Center(child: CircularProgressIndicator())
          : StatusesList(_statusList.unwrap()),
    );
  }
}
