import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/hashtag_list/hashtag_list.dart';
import 'package:pwviewer/models/results.dart';
import 'package:pwviewer/models/search_types.dart';
import 'package:pwviewer/statuses_list/statuses_list.dart';
import 'package:pwviewer/users_list/user_item.dart';
import 'package:pwviewer/utils/maybe.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _moreUsersResultExists = true;
  bool _moreStatusesResultExists = true;
  bool _moreHashtagsResultExists = true;

  Widget _buildUsersList(BuildContext context) {
    final accounts = _searchResults.map((v) =>
        v.accounts.where((element) => element.discoverable ?? true).toList());

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
          if (index == accounts.unwrap().length) {
            final args = ModalRoute.of(context)!.settings.arguments
                as SearchResultsArguments;
            final query = args.searchQuery;

            _retrieveMoreResultsOf(
                query, SearchTypes.users, accounts.unwrap().length);
            return Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return UserItem(accounts.unwrap()[index]);
          }
        }
      },
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount: _searchResults
              .map((v) => v.accounts.length + (_moreUsersResultExists ? 1 : 0))
              .unwrapOrNull() ??
          1,
    );
  }

  // TODO: read more 対応
  Widget _buildStatusesList(BuildContext context) {
    final statuses = _searchResults.map((v) => v.statuses);

    if (statuses.isNothing()) {
      return ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    } else {
      // return StatusesList(statuses.unwrap());
      if (statuses.unwrap().isEmpty) {
        return Center(
          child: Text('結果なし'),
        );
      } else {
        return StatusesList(statuses.unwrap());
      }
    }
  }

  Widget _buildHashtagsList(BuildContext context) {
    final tags = _searchResults.map((v) => v.hashtags);

    if (tags.isNothing()) {
      return ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    } else {
      if (tags.unwrap().isEmpty) {
        return Center(
          child: Text('結果なし'),
        );
      } else {
        if (_moreHashtagsResultExists) {
          return HashtagList.withReadMore(tags.unwrap(), () {
            final args = ModalRoute.of(context)!.settings.arguments
                as SearchResultsArguments;
            _retrieveMoreResultsOf(
                args.searchQuery, SearchTypes.hashtags, tags.unwrap().length);
          });
        } else {
          return HashtagList(tags.unwrap());
        }
      }
    }
  }

  Future _retrieveMoreResultsOf(
      String searchQuery, SearchTypes type, int offset) async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY);

    final uri =
        Uri.parse(getSearchWithTypeUrl(searchQuery, type, offset: offset));
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

      switch (type) {
        case SearchTypes.users:
          if (results.accounts.isEmpty) {
            setState(() {
              _moreUsersResultExists = false;
            });
          } else {
            setState(() {
              _searchResults.unwrapOrNull()?.accounts.addAll(results.accounts);
              _moreUsersResultExists = true;
            });
          }
          break;
        case SearchTypes.statuses:
          if (results.statuses.isEmpty) {
            setState(() {
              _moreStatusesResultExists = false;
            });
          } else {
            setState(() {
              _searchResults.unwrapOrNull()?.statuses.addAll(results.statuses);
              _moreStatusesResultExists = true;
            });
          }
          break;
        case SearchTypes.hashtags:
          if (results.hashtags.isEmpty) {
            setState(() {
              _moreHashtagsResultExists = false;
            });
          } else {
            setState(() {
              _searchResults.unwrapOrNull()?.hashtags.addAll(results.hashtags);
              _moreHashtagsResultExists = true;
            });
          }
          break;
      }

      // setState(() {
      //   switch (type) {
      //     case SearchTypes.users:
      //       _searchResults.unwrapOrNull()?.accounts.addAll(results.accounts);
      //       break;
      //     case SearchTypes.statuses:
      //       _searchResults.unwrapOrNull()?.statuses.addAll(results.statuses);
      //       break;
      //     case SearchTypes.hashtags:
      //       _searchResults.unwrapOrNull()?.hashtags.addAll(results.hashtags);
      //       break;
      //   }
      // });
    } else {
      final snackBar = SnackBar(
        content: Container(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text(''),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
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

    return DefaultTabController(
      length: SearchTypes.values.length,
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
              if (newQuery != '') {
                final args = SearchResultsArguments(newQuery);
                Navigator.pushNamed(
                  context,
                  SearchResults.routeName,
                  arguments: args,
                );
              }
            },
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
          bottom: TabBar(
            tabs: SearchTypes.values
                .map(
                  (e) => Tab(text: e.toString().split('.').last),
                )
                .toList(),
          ),
        ),
        body: TabBarView(
          children: SearchTypes.values.map((e) {
            switch (e) {
              case SearchTypes.users:
                return _buildUsersList(context);
              case SearchTypes.statuses:
                return _buildStatusesList(context);
              case SearchTypes.hashtags:
                return _buildHashtagsList(context);
            }
          }).toList(),
        ),
      ),
    );
  }
}
