import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/status.dart';

const LOCAL_TIMELINE_URL_WITH_LIMIT =
    'https://pawoo.net/api/v1/timelines/public/?local=true&limit=';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  int _limit = 50;
  List<Status> _statusList = [];

  Widget _buildTile(BuildContext context, int index) {
    final status = _statusList[index];

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            status.account.displayName,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Text(
            status.content,
          )
        ],
      ),
    );
  }

  void retrieveTimeline() async {
    final uri = Uri.parse(LOCAL_TIMELINE_URL_WITH_LIMIT + _limit.toString());
    final res = await http.get(uri);
    final statusList = jsonDecode(res.body);

    setState(() {
      _statusList = statusList
          .cast<Map<String, dynamic>>()
          .map((e) => Status.fromJson(e))
          .cast<Status>()
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _statusList = [];
    });

    retrieveTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: _buildTile,
        separatorBuilder: (ctx, idx) => Divider(),
        itemCount: _statusList.length);
  }
}
