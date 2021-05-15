import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const LOCAL_TIMELINE_URL =
    'https://pawoo.net/api/v1/timelines/public/?local=true&limit=50';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  // int _limit = 50;
  List<dynamic> _states = [];

  Widget _buildTile(BuildContext context, int index) {
    final state = _states[index];

    return Container(
      padding: EdgeInsets.all(16),
      // child: Text(
      //   '#$index',
      //   style: Theme.of(context).textTheme.subtitle2,
      // ),
      child: Column(
        children: [
          Text(
            state['account']['display_name'],
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Text(
            state['content'],
          )
        ],
      ),
    );
  }

  void retrieveTimeline() async {
    final uri = Uri.parse(LOCAL_TIMELINE_URL);
    final res = await http.get(uri);
    final states = jsonDecode(res.body);

    setState(() {
      _states = states;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _states = [];
    });

    retrieveTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: _buildTile,
        separatorBuilder: (ctx, idx) => Divider(),
        itemCount: _states.length);
  }
}
