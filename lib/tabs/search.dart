import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/search_results/search_results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _authorized = true; // falseだと認証済みでも一瞬ログイン要求が表示される
  String _searchQuery = '';

  Widget _buildSearchForm(BuildContext context) {
    return Card(
      elevation: 8.0,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enabled: true,
              decoration: InputDecoration(labelText: '検索クエリ'),
              onChanged: (s) {
                setState(() {
                  _searchQuery = s;
                });
              },
            ),
            Container(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    disabledElevation: 0.0,
                    backgroundColor: (!_authorized || _searchQuery.isEmpty)
                        ? Colors.grey
                        : Theme.of(context).accentColor,
                    onPressed: (!_authorized || _searchQuery.isEmpty)
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();

                            final args = SearchResultsArguments(_searchQuery);
                            Navigator.pushNamed(
                                context, SearchResults.routeName,
                                arguments: args);
                          },
                    child: Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledMessage(BuildContext context) {
    return Card(
      elevation: 8.0,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Flexible(
              flex: 0,
              child: Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
            ),
            Flexible(
              flex: 0,
              child: Container(width: 16),
            ),
            Flexible(
              flex: 1,
              child: Text('検索を行うには認証が必要です\n設定画面から認証キーを設定してください'),
            ),
          ],
        ),
      ),
    );
  }

  Future _checkIfAuthorized() async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY);

    setState(() {
      _authorized = authKey != null;
    });
  }

  @override
  void initState() {
    super.initState();

    _checkIfAuthorized();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchForm(context),
          _authorized ? Container() : _buildDisabledMessage(context),
        ],
      ),
    );
  }
}
