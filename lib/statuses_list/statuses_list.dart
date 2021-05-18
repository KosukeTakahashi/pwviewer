import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/statuses_list/status_item.dart';
import 'package:pwviewer/utils/maybe.dart';

class StatusesList extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  final List<Status> statuses;
  final Maybe<void Function()> readMoreCallback;

  StatusesList(this.statuses) : readMoreCallback = Maybe.nothing();

  StatusesList.withReadMore(this.statuses, void Function() readMoreCallback)
      : readMoreCallback = Maybe.some(readMoreCallback);

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

  Widget _buildTile(BuildContext context, int index) {
    if (index == widget.statuses.length) {
      widget.readMoreCallback.unwrap()();

      return Container(
        padding: EdgeInsets.all(8),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: StatusItem(widget.statuses[index], _launchBrowser),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // itemBuilder: (context, index) => Container(
      //   padding: EdgeInsets.only(left: 8, right: 8),
      //   child: StatusItem(widget.statuses[index], _launchBrowser),
      // ),
      itemBuilder: _buildTile,
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount: widget.statuses.length +
          (widget.readMoreCallback.isNothing() ? 0 : 1),
    );
  }
}
