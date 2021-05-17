import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as html;
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/statuses_list/status_item.dart';
import 'package:pwviewer/utils/content_parser.dart';

class Reply extends StatelessWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  final Status status;

  Reply(this.status);

  Future _launchBrowser(String url) async {
    await browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  // Widget _buildAvatar(BuildContext context, Account account) {
  //   return Avatar(account, 48);
  // }

  // Widget _buildHeader(BuildContext context, Account account) {
  //   return Row(
  //     children: [
  //       Text(account.displayName),
  //       Container(
  //         width: 8,
  //       ),
  //       Text(
  //         '@${account.username}',
  //         style: Theme.of(context).textTheme.caption,
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildContent(BuildContext context, Status status) {
  //   final parsed = html.parse(status.content);
  //   final paragraphs = parsed.querySelectorAll('p');
  //   final contents =
  //       paragraphs.map((e) => parseContent(context, e, _launchBrowser));

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: contents
  //         .map((e) => RichText(
  //               text: e,
  //               textScaleFactor: MediaQuery.of(context).textScaleFactor,
  //             ))
  //         .toList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StatusItem(status, _launchBrowser);
    // return Container(
    //   padding: EdgeInsets.only(bottom: 8),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Container(
    //         padding: EdgeInsets.only(
    //           top: 4,
    //           bottom: 4,
    //         ),
    //         child: _buildAvatar(context, status.account),
    //       ),
    //       Container(
    //           padding: EdgeInsets.only(left: 16),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               _buildHeader(context, status.account),
    //               _buildContent(context, status),
    //             ],
    //           ))
    //     ],
    //   ),
    // );
  }
}
