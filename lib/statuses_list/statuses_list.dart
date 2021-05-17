import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/statuses_list/status_item.dart';

class StatusesList extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  final List<Status> statuses;

  StatusesList(this.statuses);

  @override
  _StatusesListState createState() => _StatusesListState();
}

class _StatusesListState extends State<StatusesList> {
  Future _launchBrowser(String url) async {
    await widget.browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: StatusItem(widget.statuses[index], _launchBrowser),
      ),
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount: widget.statuses.length,
    );
  }
}
