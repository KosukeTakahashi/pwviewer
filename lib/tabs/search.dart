import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwviewer/search_results/search_results.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
                    onPressed: () {
                      HapticFeedback.mediumImpact();

                      final args = SearchResultsArguments(_searchQuery);
                      Navigator.pushNamed(context, SearchResults.routeName,
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

  @override
  void initState() {
    super.initState();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: _buildSearchForm(context),
    );
  }
}
