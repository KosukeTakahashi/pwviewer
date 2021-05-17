import 'package:flutter/material.dart';
import 'package:pwviewer/media_viewer/media_viewer.dart';
import 'package:pwviewer/search_results/search_results.dart';
import 'package:pwviewer/status_details/status_details.dart';
import 'package:pwviewer/user_details/user_details.dart';
import 'home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PwViewer',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: Home.routeName,
      routes: {
        Home.routeName: (context) => Home(),
        MediaViewer.routeName: (context) => MediaViewer(),
        StatusDetails.routeName: (context) => StatusDetails(),
        UserDetails.routeName: (context) => UserDetails(),
        SearchResults.routeName: (context) => SearchResults(),
      },
    );
  }
}
