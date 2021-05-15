import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../models/status.dart';
import '../../models/account.dart';
import '../../models/attachment.dart';
import 'content_parser.dart';

const LOCAL_TIMELINE_URL_WITH_LIMIT =
    'https://pawoo.net/api/v1/timelines/public/?local=true&limit=';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  int _limit = 50;
  List<Status> _statusList = [];

  Widget _buildAvatar(BuildContext context, Account account) {
    return Container(
        padding: EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.network(
            account.avatar,
            width: 48,
            height: 48,
          ),
        ));
  }

  Widget _buildHeadline(BuildContext context, Status status) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Text(
            status.account.displayName,
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
            flex: 0,
            child: Container(
              width: 4,
            )),
        Flexible(
          flex: 0,
          child: Text(
            '@${status.account.username}',
            style: Theme.of(context).textTheme.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Status status) {
    final parsed = html.parse(status.content);
    final paragraphs = parsed.querySelectorAll('p');
    final contents = paragraphs.map((e) => parseContent(e)).toList();

    // return Text(status.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents
          .map((e) => RichText(
                text: e,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ))
          .toList(),
    );
  }

  Widget _buildAttachments(BuildContext context, List<Attachment> attachments) {
    return Column(
      children: attachments.map((attachment) {
        return Container(
          padding: EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(attachment.previewUrl),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrailer(BuildContext context, Status status) {
    return Text(
      status.createdAt,
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildActions(BuildContext context, Status status) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 24,
                  child: Icon(
                    Icons.comment_outlined,
                    size: 14,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(status.repliesCount.toString()),
                ),
              ],
            ),
          ),
          // label: Text(status.favouritesCount.toString()),
        ),
        Flexible(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 24,
                  child: Icon(
                    Icons.repeat_outlined,
                    size: 14,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(status.reblogsCount.toString()),
                ),
              ],
            ),
          ),
          // label: Text(status.favouritesCount.toString()),
        ),
        Flexible(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 24,
                  child: Icon(
                    Icons.favorite_outline,
                    size: 14,
                    color: status.favourited != null && (status.favourited!)
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyText1?.color,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    status.favouritesCount.toString(),
                    style: TextStyle(
                      color: status.favourited != null && (status.favourited!)
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // label: Text(status.favouritesCount.toString()),
        ),
        Flexible(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: 14,
              height: 24,
              child: Icon(
                Icons.share_outlined,
                size: 14,
              ),
            ),
            // label: Text(status.favouritesCount.toString()),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, int index) {
    final status = _statusList[index];

    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 0,
              child: _buildAvatar(context, status.account),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeadline(context, status),
                    _buildContent(context, status),
                    _buildAttachments(context, status.mediaAttachments),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: _buildTrailer(context, status),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: _buildActions(context, status),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future _retrieveTimeline() async {
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

    _retrieveTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _retrieveTimeline,
      child: ListView.separated(
        itemBuilder: _buildTile,
        separatorBuilder: (ctx, idx) => Divider(),
        itemCount: _statusList.length,
      ),
    );
  }
}
