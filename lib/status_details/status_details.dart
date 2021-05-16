import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/utils/content_parser.dart';

class StatusDetailsArguments {
  final Status status;

  StatusDetailsArguments(this.status);
}

class StatusDetails extends StatelessWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  static final String routeName = '/status_details';

  Future _launchBrowser(String url) async {
    await browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Account account) {
    return Container(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Image.network(
        account.avatar,
        width: 64,
        height: 64,
      ),
    ));
  }

  Widget _buildHeadline(BuildContext context, Account account) {
    // final dateFormat = DateFormat('yyyy/MM/dd hh:mm:ss');
    // final dateTimeString = dateFormat.format(DateTime.parse(status.createdAt));

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(attachment.previewUrl),
                ),
                onTap: () {
                  final args = MediaViewerArguments(attachment);
                  Navigator.pushNamed(context, MediaViewer.routeName,
                      arguments: args);
                },
              ))
          .toList(),
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
          ' Favourites',
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
          ' Reblogs',
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
            child: Column(
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
                          child: _buildAvatar(context, args.status.account),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(left: 16),
                          child: _buildHeadline(context, args.status.account),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 24),
                  child: _buildContent(context, args.status),
                ),
                Container(
                  padding: EdgeInsets.only(top: 24),
                  child:
                      _buildAttachments(context, args.status.mediaAttachments),
                ),
                Divider(),
                _buildFavouritesCounter(context, args.status),
                Divider(),
                _buildReblogsCounter(context, args.status),
                Divider(),
                _buildActions(context, args.status),
                Divider(),
              ],
            ),
          ));
    }
  }
}
