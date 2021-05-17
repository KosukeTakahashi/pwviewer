import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/placeholders/text_placeholder.dart';
import 'package:pwviewer/status_details/status_details.dart';
import 'package:pwviewer/utils/content_parser.dart';
import 'package:pwviewer/utils/query_urls.dart';

class StatusItem extends StatelessWidget {
  final Status _status;
  final Future Function(String) _launchBrowser;
  final bool _isReplyAncestor;
  final bool _allowJump;

  StatusItem(this._status, this._launchBrowser)
      : _isReplyAncestor = false,
        _allowJump = true;

  StatusItem.replyAncestor(this._status, this._launchBrowser)
      : _isReplyAncestor = true,
        _allowJump = true;

  StatusItem.prohibitJump(this._status, this._launchBrowser)
      : _isReplyAncestor = false,
        _allowJump = false;

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
            style: Theme.of(context)
                .textTheme
                .subtitle2
                ?.apply(fontWeightDelta: 1),
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

/*
  Widget _buildInReplyTo(BuildContext context, Status status) {
    if (status.inReplyToAccountId == null) {
      return Container();
    } else {
      return FutureBuilder(future: () async {
        final uri = Uri.parse(getAccountUrl(status.inReplyToAccountId!));
        final res = await http.get(uri);

        if (res.statusCode == 200) {
          final account = Account.fromJson(jsonDecode(res.body));

          return account;
        } else {
          return Future.error('Server returned code ${res.statusCode}');
        }
      }(), builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState != ConnectionState.done) {
          return TextPlaceholder();
        } else {
          if (dataSnapshot.hasError) {
            return Text('<<${dataSnapshot.error}>>');
          } else {
            final account = dataSnapshot.data as Account;

            return Row(
              children: [
                Text(
                  '返信先：',
                  style: Theme.of(context).textTheme.caption,
                ),
                RichText(
                  text: TextSpan(
                    text: '@${account.username}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.apply(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        HapticFeedback.mediumImpact();
                      },
                  ),
                ),
              ],
            );
          }
        }
      });
    }
  }
*/

  Widget _buildContent(BuildContext context, Status status) {
    final parsed = html.parse(status.content);
    final paragraphs = parsed.querySelectorAll('p');
    final contents = paragraphs
        .map((e) => parseContent(context, e, status.emojis, _launchBrowser))
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
                    color: status.favourited != null &&
                            (status.favourited ?? false)
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyText1?.color,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    status.favouritesCount.toString(),
                    style: TextStyle(
                      color: status.favourited != null &&
                              (status.favourited ?? false)
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
      onTap: !_allowJump
          ? null
          : () {
              // final args = StatusDetailsArguments(_status.id);
              final args = _status.reblog == null
                  ? StatusDetailsArguments(_status.id)
                  : StatusDetailsArguments.reblogged(
                      _status.reblog!.id,
                      _status.account,
                    );

              Navigator.pushNamed(context, StatusDetails.routeName,
                  arguments: args);
            },
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: _status.reblog == null
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: _isReplyAncestor
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 0,
                        // child: _buildAvatar(context, _status.account),
                        child: !_isReplyAncestor
                            ? _buildAvatar(context, _status.account)
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 0,
                                    child:
                                        _buildAvatar(context, _status.account),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: 2.0,
                                      // height: 20,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              )),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeadline(context, _status),
                            // Container(
                            //   padding: EdgeInsets.only(top: 4),
                            //   child: _buildInReplyTo(context, _status),
                            // ),
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
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 64),
                    child: Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          color: Theme.of(context).textTheme.caption!.color,
                          size: Theme.of(context).textTheme.caption!.fontSize,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            '${_status.account.displayName} さんがブースト',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusItem.prohibitJump(_status.reblog!, _launchBrowser),
                ],
              ),
      ),
    );
  }
}
