import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/in_app_browser/my_chrome_safari_browser.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/models/status.dart';
import 'package:pwviewer/statuses_list/status_item.dart';
import 'package:pwviewer/utils/content_parser.dart';
import 'package:pwviewer/utils/maybe.dart';
import 'package:pwviewer/utils/query_urls.dart';

class UserDetailsArguments {
  final String accountId;

  UserDetailsArguments(this.accountId);
}

class UserDetails extends StatefulWidget {
  static final routeName = '/user_details';
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _statusesRetrievalUnit = 50;

  Maybe<Account> _account = Maybe.nothing();
  Maybe<List<Status>> _statuses = Maybe.nothing();
  Maybe<String> _nextAccountStatusesUrl = Maybe.nothing();

  Future _launchBrowser(String url) async {
    await widget.browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Account account) {
    return Image.network(account.header);
  }

  Widget _buildAvatar(BuildContext context, Account account) {
    return Avatar(account, 64, false);
  }

  Widget _buildNames(BuildContext context, Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.displayName,
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          '@${account.username}',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Widget _buildFollowerFollowing(BuildContext context, Account account) {
    return Row(
      children: [
        Text(account.followersCount.toString()),
        Text(' フォロワー', style: Theme.of(context).textTheme.caption),
        Container(width: 16),
        Text(account.followingCount.toString()),
        Text(' フォロー中', style: Theme.of(context).textTheme.caption)
      ],
    );
  }

  Widget _buildNote(BuildContext context, Account account) {
    final parsed = html.parse(account.note);
    final paragraphs = parsed.querySelectorAll('p');
    final contents =
        paragraphs.map((e) => parseContent(context, e, _launchBrowser));

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

  Widget _buildStatusesCounter(BuildContext context, Account account) {
    return Row(
      children: [
        Text(account.statusesCount.toString()),
        Text(' 件の投稿', style: Theme.of(context).textTheme.caption)
      ],
    );
  }

  Widget _buildBaseInfo(BuildContext context, Account account) {
    return Column(
      children: [
        _account.isNothing()
            ? Container()
            : _buildHeader(context, _account.unwrap()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              child: _buildAvatar(context, account),
            ),
            Container(
              padding: EdgeInsets.only(left: 24),
              child: _buildNames(context, account),
            ),
            Container(
              padding: EdgeInsets.only(top: 12, left: 24, right: 24),
              child: _buildNote(context, account),
            ),
            Container(
                padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                child: _buildFollowerFollowing(context, account)),
            Container(
              padding:
                  EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
              child: _buildStatusesCounter(context, account),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoader(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildTiles(BuildContext context, int index) {
    if (_account.isNothing()) {
      return Container(
        height: 200,
        child: _buildLoader(context),
      );
    } else {
      if (index == 0) {
        return _buildBaseInfo(context, _account.unwrap());
      } else {
        if (_statuses.isNothing()) {
          return Container(
            height: 100,
            child: _buildLoader(context),
          );
        } else {
          if (index <= _statuses.unwrap().length) {
            return Container(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: StatusItem(_statuses.unwrap()[index - 1], _launchBrowser),
            );
          } else {
            final args = ModalRoute.of(context)!.settings.arguments
                as UserDetailsArguments;
            _retrieveStatuses(args.accountId);
            return Container(
              height: 100,
              child: _buildLoader(context),
            );
          }
        }
      }
    }
  }

  Future _retrieveAccount(String accountId) async {
    final uri = Uri.parse(getAccountUrl(accountId));
    final res = await http.get(uri);
    final account = Account.fromJson(jsonDecode(res.body));

    setState(() {
      _account = Maybe.some(account);
    });
  }

  Future _retrieveStatuses(String accountId) async {
    // final uri = Uri.parse(getAccountStatusesUrl(accountId, 50));
    final uri = Uri.parse(_nextAccountStatusesUrl.isNothing()
        ? getAccountStatusesUrl(accountId, limit: _statusesRetrievalUnit)
        : _nextAccountStatusesUrl.unwrap());
    final res = await http.get(uri);
    // final nextPage = res.headers['link']?.split(';').first;
    final statuses = jsonDecode(res.body)
        .cast<Map<String, dynamic>>()
        .map((e) => Status.fromJson(e))
        .cast<Status>()
        .toList();

    var nextPage = res.headers['link']!.split(';').first;
    nextPage = nextPage.substring(1, nextPage.length - 1);

    if (_statuses.isNothing()) {
      setState(() {
        _nextAccountStatusesUrl = Maybe.some(nextPage);
        _statuses = Maybe.some(statuses);
      });
    } else {
      setState(() {
        _nextAccountStatusesUrl = Maybe.some(nextPage);
        _statuses = Maybe.some(_statuses.unwrap()..addAll(statuses));
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args =
          ModalRoute.of(context)?.settings.arguments as UserDetailsArguments?;

      if (args != null) {
        _retrieveAccount(args.accountId);
        _retrieveStatuses(args.accountId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as UserDetailsArguments?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(child: Text('The argument was null')),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: _account.isNothing()
              ? Text('')
              : Text(_account.unwrap().displayName),
        ),
        body: ListView.separated(
          itemBuilder: _buildTiles,
          separatorBuilder: (ctx, idx) => Divider(),
          itemCount:
              // _account.isNothing() ? 1 : _account.unwrap().statusesCount + 1,
              _statuses.isNothing()
                  ? 1
                  : 1 +
                      min(
                        _account.unwrapOrNull()?.statusesCount ?? 0,
                        _statuses.unwrap().length + 1,
                      ),
        ),
      );
    }
  }
}
