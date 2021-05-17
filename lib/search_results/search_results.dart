import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/models/results.dart';
import 'package:pwviewer/users_list/user_item.dart';
import 'package:pwviewer/utils/maybe.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _ResultOf {
  users,
  statuses,
  hashtags,
}

class SearchResultsArguments {
  String searchQuery;

  SearchResultsArguments(this.searchQuery);
}

class SearchResults extends StatefulWidget {
  static final String routeName = '/search_results';

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  Maybe<Results> _searchResults = Maybe.nothing();

  Widget _buildUsersList(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (_searchResults.isNothing()) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return UserItem(
              _searchResults.map((v) => v.accounts[index]).unwrap());
        }
      },
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount:
          _searchResults.map((v) => v.accounts.length).unwrapOrNull() ?? 1,
    );
  }

  Future _retrieveResults(String searchQuery) async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY);

    final uri = Uri.parse(getSearchUrl(searchQuery));
    final res = await http.get(
      uri,
      headers: authKey != null
          ? {
              REQUEST_HEADER_AUTHORIZATION:
                  REQUEST_HEADER_AUTHORIZATION_PREFIX + authKey
            }
          : {},
    );

    if (res.statusCode == 200) {
      final results = Results.fromJson(jsonDecode(res.body));
      setState(() {
        _searchResults = Maybe.some(results);
      });
    } else {
      setState(() {
        _searchResults = Maybe.nothing();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args =
          ModalRoute.of(context)?.settings.arguments as SearchResultsArguments?;
      if (args != null) {
        _retrieveResults(args.searchQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as SearchResultsArguments?;

    return Center(
      child: DefaultTabController(
        length: _ResultOf.values.length,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: TextFormField(
              initialValue: args?.searchQuery ?? '',
              decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (newQuery) {
                final args = SearchResultsArguments(newQuery);
                Navigator.pushNamed(
                  context,
                  SearchResults.routeName,
                  arguments: args,
                );
              },
            ),
            bottom: TabBar(
              tabs: _ResultOf.values
                  .map(
                    (e) => Tab(text: e.toString().split('.').last),
                  )
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: _ResultOf.values.map((e) {
              if (e == _ResultOf.users) {
                return _buildUsersList(context);
              } else {
                return Text(e.toString());
              }
            }).toList(),
          ),
        ),
      ),
    );
  }
}
