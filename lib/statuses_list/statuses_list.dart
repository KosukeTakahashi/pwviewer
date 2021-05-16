import 'package:flutter/gestures.dart';
import 'package:html/parser.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/status_details/status_details.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';

TextSpan parseContent(dom.Element element, Future Function(String) urlOpen) {
  if (element.children.length == 0) {
    return TextSpan(text: element.text);
  } else {
    return TextSpan(
      children: element.children.map((e) {
        if (e.localName == 'a') {
          return TextSpan(
            text: e.text,
            // <a></a>に子要素はないものの仮定する
            // children: e.children.map((f) => parseContent(f)).toList(),
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                HapticFeedback.mediumImpact();
                // とりあえず '#' で始まるか否かでハッシュタグかを判定
                final isHashTag = e.text.startsWith('#');

                if (!isHashTag) {
                  final url = e.attributes['href'];
                  if (url != null) {
                    // open URL
                    urlOpen(url);
                  }
                }
              },
          );
        } else {
          return TextSpan(
              children:
                  e.children.map((f) => parseContent(f, urlOpen)).toList());
        }
      }).toList(),
    );
  }
}

class StatusesList extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  List<Status> statuses;

  StatusesList(this.statuses);

  @override
  _StatusesListState createState() => _StatusesListState();
}

class _StatusesListState extends State<StatusesList> {
  // List<Status> _statusList = [];

  Future _launchBrowser(String url) async {
    await widget.browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  void _openMediaViewer(BuildContext context, Attachment attachment) {
    Navigator.pushNamed(
      context,
      MediaViewer.routeName,
      arguments: MediaViewerArguments(attachment),
    );
  }

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
    final contents =
        paragraphs.map((e) => parseContent(e, _launchBrowser)).toList();

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
            child: GestureDetector(
              child: Image.network(attachment.previewUrl),
              onTap: () {
                _openMediaViewer(context, attachment);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrailer(BuildContext context, Status status) {
    final dt = DateTime.parse(status.createdAt);
    final formatted =
        '${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';
    return Text(
      formatted,
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
    final status = widget.statuses[index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final args = StatusDetailsArguments(status);

        Navigator.pushNamed(context, StatusDetails.routeName, arguments: args);
      },
      child: Container(
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
          )),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: _buildTile,
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount: widget.statuses.length,
    );
  }
}
