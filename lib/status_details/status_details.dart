import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/models/status_context.dart';
import 'package:pwviewer/status_details/reply.dart';
import 'package:pwviewer/utils/content_parser.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:pwviewer/utils/maybe.dart';

class StatusDetailsArguments {
  final String statusId;

  StatusDetailsArguments(this.statusId);
}

class StatusDetails extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  static final String routeName = '/status_details';

  @override
  _StatusDetailsState createState() => _StatusDetailsState();
}

class _StatusDetailsState extends State<StatusDetails> {
  Maybe<Status> _status = Maybe.nothing();
  Maybe<StatusContext> _statusContext = Maybe.nothing();

  Future _launchBrowser(String url) async {
    await widget.browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Account account) {
    return Container(
      child: Avatar(account, 64),
    );
  }

  Widget _buildHeadline(BuildContext context, Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          account.displayName,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Text(
          '@${account.username}',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Status status) {
    final parsed = html.parse(status.content);
    final paragraphs = parsed.querySelectorAll('p');
    final contents =
        paragraphs.map((e) => parseContent(context, e, _launchBrowser));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents
          .map((e) => RichText(
                text: e,
                textScaleFactor: MediaQuery.of(context).textScaleFactor * 1.5,
              ))
          .toList(),
    );
  }

  Widget _buildAttachments(BuildContext context, List<Attachment> attachments) {
    return Column(
      children: attachments
          .map((attachment) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(attachment.previewUrl),
                    )),
                onTap: () {
                  final args = MediaViewerArguments(attachment);
                  Navigator.pushNamed(context, MediaViewer.routeName,
                      arguments: args);
                },
              ))
          .toList(),
    );
  }

  Widget _buildTrailer(BuildContext context, Status status) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss');
    final dateTimeString =
        dateFormat.format(DateTime.parse(status.createdAt).toLocal());

    return Text(
      dateTimeString,
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildFavouritesCounter(BuildContext context, Status status) {
    return Row(
      children: [
        Text(
          status.favouritesCount.toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Text(
          '件のお気に入り',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Widget _buildReblogsCounter(BuildContext context, Status status) {
    return Row(
      children: [
        Text(
          status.reblogsCount.toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Text(
          '件のブースト',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Status status) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Icon(
              Icons.comment_outlined,
              color: Colors.grey,
              // size: 14,
            ),
          ),
          // label: Text(status.favouritesCount.toString()),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Icon(
              Icons.repeat_outlined,
              color: Colors.grey,
              // size: 14,
            ),
          ),
          // label: Text(status.favouritesCount.toString()),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Icon(
              Icons.favorite_outline,
              // size: 14,
              color: status.favourited != null && (status.favourited!)
                  ? Colors.red
                  : Colors.grey,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Icon(
              Icons.share_outlined,
              color: Colors.grey,
              // size: 14,
            ),
          ),
        ),
        // Flexible(
        //   flex: 1,
        //   child: Container(),
        // ),
      ],
    );
  }

  Widget _buildStatusTile(BuildContext context, Status status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Flexible(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(top: 4),
                  child: _buildAvatar(context, status.account),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 16),
                  child: _buildHeadline(context, status.account),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 24),
          child: _buildContent(context, status),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 24),
          child: _buildAttachments(context, status.mediaAttachments),
        ),
        Container(
          padding: EdgeInsets.only(top: 12),
          child: _buildTrailer(context, status),
        ),
        Divider(),
        _buildFavouritesCounter(context, status),
        Divider(),
        _buildReblogsCounter(context, status),
        Divider(),
        Container(
          padding: EdgeInsets.only(bottom: 8),
          child: _buildActions(context, status),
        ),
      ],
    );
  }

  Widget _buildReplyTileOf(BuildContext context, Status status) {
    return Reply(status);
  }

  Widget Function(BuildContext, int) _getTilesBuilder(Maybe<Status> status) {
    if (status.isNothing()) {
      return (context, index) => Container(
            // padding: EdgeInsets.all(16),
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
    } else {
      return (context, index) {
        if (index == 0) {
          return _buildStatusTile(context, status.unwrap());
        } else {
          return _statusContext.isNothing()
              ? Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _buildReplyTileOf(
                  context, _statusContext.unwrap().descendants[index - 1]);
        }
      };
    }
  }

  Future _fetchStatus(String statusId) async {
    final uri = Uri.parse(getStatusUrl(statusId));
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final status = Status.fromJson(jsonDecode(res.body));

      setState(() {
        _status = Maybe.some(status);
      });
    } else {
      final snackBar =
          SnackBar(content: Text('Status Code: ${res.statusCode}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _fetchStatusContext(String statusId) async {
    final uri = Uri.parse(getStatusContextUrl(statusId));
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final context = StatusContext.fromJson(jsonDecode(res.body));

      setState(() {
        _statusContext = Maybe.some(context);
      });
    } else {
      final snackBar =
          SnackBar(content: Text('Status Code: ${res.statusCode}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args =
          ModalRoute.of(context)?.settings.arguments as StatusDetailsArguments?;
      if (args != null) {
        _fetchStatus(args.statusId);
      } else {
        setState(() {
          _statusContext = Maybe.nothing();
        });
      }
    });

    Future.delayed(Duration.zero, () {
      final args =
          ModalRoute.of(context)?.settings.arguments as StatusDetailsArguments?;
      if (args != null) {
        _fetchStatusContext(args.statusId);
      } else {
        setState(() {
          _statusContext = Maybe.nothing();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as StatusDetailsArguments?;

    final appBar = AppBar(
      leading: BackButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text('詳細'),
    );

    if (args == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Text('The argument was null'),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: ListView.separated(
            itemBuilder: _getTilesBuilder(_status),
            separatorBuilder: (ctx, idx) => Divider(),
            itemCount:
                _status.isNothing() ? 1 : _status.unwrap().repliesCount + 1,
          ),
        ),
      );
    }
  }
}
