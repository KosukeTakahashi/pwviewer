import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/statuses_list/statuses_list.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:pwviewer/utils/maybe.dart';

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
    final uri = Uri.parse(getTimelineUrl(_limit));
    final res = await http.get(uri);
    final statusList = jsonDecode(res.body);

    setState(() {
      _statusList = Maybe.some(statusList
          .cast<Map<String, dynamic>>()
          .map((e) => Status.fromJson(e))
          .cast<Status>()
          .toList());
    });
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
            : StatusesList(_statusList.unwrap()));
  }
}
