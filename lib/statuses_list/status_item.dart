import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/status_details/status_details.dart';
import 'package:pwviewer/utils/content_parser.dart';

class StatusItem extends StatelessWidget {
  final Status _status;
  final Future Function(String) _launchBrowser;

  StatusItem(this._status, this._launchBrowser);

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
      child: Avatar(account, 48),
    );
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
    final contents = paragraphs
        .map((e) => parseContent(context, e, _launchBrowser))
        .toList();

    // return Text(status.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents
          .map(
            (e) => Container(
              padding: EdgeInsets.only(top: 4),
              child: RichText(
                text: e,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAttachments(BuildContext context, List<Attachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss');
    final dateTimeString =
        dateFormat.format(DateTime.parse(status.createdAt).toLocal());
    return Text(
      dateTimeString,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final args = StatusDetailsArguments(_status.id);

        Navigator.pushNamed(context, StatusDetails.routeName, arguments: args);
      },
      child: Container(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 0,
                child: _buildAvatar(context, _status.account),
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
                      _buildHeadline(context, _status),
                      _buildContent(context, _status),
                      Container(
                        width: double.infinity,
                        child: _buildAttachments(
                            context, _status.mediaAttachments),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        child: _buildTrailer(context, _status),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        child: _buildActions(context, _status),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
